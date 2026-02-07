-- Full transitive graph:
-- 1) product -> product_group (explicit via link, then implicit via ancestors)
-- 2) product_group -> parent product_group (explicit child->parent, then implicit ancestors)
-- 3) top-level product_group -> synthetic 'Global' node

WITH RECURSIVE product_group_hierarchy AS (
    -- Base: direct product -> group links (EXPLICIT)
    SELECT
        p.center                                AS fromlink__center,
        p.id                                    AS fromlink__id,
        p.name                                  AS fromlink__name,
        'PRODUCT'::text                         AS fromlink__type,
        NULL::int                               AS tolink__center,
        pg.id                                   AS tolink__id,
        pg.name                                 AS tolink__name,
        'PRODUCT_GROUP'::text                   AS tolink__type,
        (p.primary_product_group_id = pg.id)    AS is_primary,
        TRUE                                    AS is_explicit
    FROM products AS p
    JOIN product_and_product_group_link AS link
      ON link.product_center = p.center
     AND link.product_id     = p.id
    JOIN product_group AS pg
      ON pg.id = link.product_group_id
    WHERE p.center = 100
      AND p.ptype  = 10
	  AND p.blocked = FALSE

    UNION ALL

    -- Recursive: climb group -> parent group (IMPLICIT for products)
    SELECT
        h.fromlink__center                      AS fromlink__center,
        h.fromlink__id                          AS fromlink__id,
        h.fromlink__name                        AS fromlink__name,
        h.fromlink__type                        AS fromlink__type,
        NULL::int                               AS tolink__center,
        parent.id                               AS tolink__id,
        parent.name                             AS tolink__name,
        'PRODUCT_GROUP'::text                   AS tolink__type,
        FALSE                                   AS is_primary,
        FALSE                                   AS is_explicit
    FROM product_group_hierarchy AS h
    JOIN product_group AS current
      ON current.id = h.tolink__id
    JOIN product_group AS parent
      ON parent.id = current.parent_product_group_id
),
group_edges AS (
    -- Direct group -> parent group edges (EXPLICIT)
    SELECT
        NULL::int               AS fromlink__center,
        child.id                AS fromlink__id,
        child.name              AS fromlink__name,
        'PRODUCT_GROUP'::text   AS fromlink__type,
        NULL::int               AS tolink__center,
        parent.id               AS tolink__id,
        parent.name             AS tolink__name,
        'PRODUCT_GROUP'::text   AS tolink__type,
        NULL::boolean           AS is_primary,
        TRUE                    AS is_explicit
    FROM product_group AS child
    JOIN product_group AS parent
      ON parent.id = child.parent_product_group_id
),
group_edges_recursive AS (
    -- Implicit group -> ancestor group edges
    SELECT * FROM group_edges
    UNION ALL
    SELECT
        ge.fromlink__center,
        ge.fromlink__id,
        ge.fromlink__name,
        ge.fromlink__type,
        NULL::int               AS tolink__center,
        gp.id                   AS tolink__id,
        gp.name                 AS tolink__name,
        'PRODUCT_GROUP'::text   AS tolink__type,
        NULL::boolean           AS is_primary,
        FALSE                   AS is_explicit
    FROM group_edges_recursive AS ge
    JOIN product_group AS parent
      ON parent.id = ge.tolink__id
    JOIN product_group AS gp
      ON gp.id = parent.parent_product_group_id
),
top_groups AS (
    -- Top-level product_group -> synthetic 'Global' node
    SELECT
        NULL::int               AS fromlink__center,
        pg.id                   AS fromlink__id,
        pg.name                 AS fromlink__name,
        'PRODUCT_GROUP'::text   AS fromlink__type,
        NULL::int               AS tolink__center,
        -1                      AS tolink__id,      -- <== requested fill
        'Global'                AS tolink__name,    -- <== requested fill
        'GLOBAL'::text          AS tolink__type,    -- <== requested fill
        FALSE                   AS is_primary,      -- <== requested fill
        TRUE                    AS is_explicit      -- <== requested fill
    FROM product_group AS pg
    WHERE pg.parent_product_group_id IS NULL
)
SELECT * FROM product_group_hierarchy
UNION ALL
SELECT * FROM group_edges_recursive
UNION ALL
SELECT * FROM top_groups
ORDER BY fromlink__type, fromlink__id, tolink__type NULLS LAST, tolink__id NULLS LAST, is_explicit DESC;
