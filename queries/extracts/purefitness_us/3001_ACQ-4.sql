WITH
    PRODUCT AS
    (
        SELECT
            mpr.id,
            p.name,
            p.center
        FROM
            masterproductregister mpr
        JOIN
            products p
        ON
            p.globalid = mpr.globalid
        AND mpr.id = mpr.definition_key
        WHERE
            mpr.globalid = :GlobalId
        AND p.center NOT IN
            (
                SELECT
                    p.center
                FROM
                    masterproductregister mpr
                JOIN
                    products p
                ON
                    p.globalid = mpr.globalid
                AND p.center = mpr.scope_id
                AND mpr.scope_type = 'C'
                WHERE
                    mpr.globalid = :GlobalId)
    )
    ,
    PRODUCT_OVERRIDE AS
    (
        SELECT
            mpr.id,
            p.name,
            p.center
        FROM
            masterproductregister mpr
        JOIN
            products p
        ON
            p.globalid = mpr.globalid
        AND p.center = mpr.scope_id
        AND mpr.scope_type = 'C'
        WHERE
            mpr.globalid = :GlobalId
    )
SELECT
	PrivilegeSetId AS "PrivilegeSetId"
FROM (
SELECT DISTINCT
    ps.id       AS PrivilegeSetId,
	prod.center AS CENTER
FROM
    privilege_grants pg
JOIN
    privilege_sets ps
ON
    ps.ID = pg.privilege_set
AND pg.granter_service = 'GlobalSubscription'
AND pg.valid_to IS NULL
AND ps.STATE = 'ACTIVE'
JOIN
    PRODUCT prod
ON
    prod.id = pg.granter_id

UNION ALL

SELECT DISTINCT
    ps.id       AS PrivilegeSetId,
    po.center AS CENTER
FROM
    privilege_grants pg
JOIN
    privilege_sets ps
ON
    ps.ID = pg.privilege_set
AND pg.granter_service = 'GlobalSubscription'
AND pg.valid_to IS NULL
AND ps.STATE = 'ACTIVE'
JOIN
    PRODUCT_OVERRIDE po
ON
    po.id = pg.granter_id)  t1
WHERE
	CENTER = :Center