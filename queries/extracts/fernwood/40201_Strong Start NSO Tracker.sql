-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
    SELECT
        /*+ materialize */
        datetolongC('2025-12-01 00:00', c.id) AS FromDate,
        c.id AS center_id,
        datetolongC(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI'), c.id) AS ToDate
    FROM centers c
),


paid_strong_start AS
(
    SELECT
        c.shortname AS club_name,
        pro.name    AS product_name,
        (p.center || 'p' || p.id) AS person_id,
        COALESCE(inv.total_amount, 0) AS amount_paid,
        t.entry_time AS entry_time
    FROM persons p
    JOIN clipcards cc
        ON cc.owner_center = p.center
       AND cc.owner_id     = p.id
    JOIN centers c
        ON c.id = p.center
    JOIN products pro
        ON pro.center = cc.center
       AND pro.id     = cc.ID
    JOIN params
        ON params.center_id = c.id
    JOIN product_and_product_group_link pgl
        ON pgl.product_center   = pro.center
       AND pgl.product_id       = pro.id
       AND pgl.product_group_id IN (18801, 224, 237)
    LEFT JOIN invoice_lines_mt inv
        ON cc.invoiceline_center = inv.center
       AND cc.invoiceline_id     = inv.id
       AND cc.invoiceline_subid  = inv.subid
    LEFT JOIN invoices t
        ON cc.invoiceline_center = t.center
       AND cc.invoiceline_id     = t.id
    WHERE
        p.status NOT IN (4,5,7,8)
        AND p.center IN (:Scope)
        AND pro.name ILIKE '%Strong%Start%Challenge%'
        AND t.entry_time BETWEEN params.FromDate AND params.ToDate
        AND COALESCE(inv.total_amount, 0) > 0
),


chosen AS
(
    SELECT
        club_name,
        product_name,
        person_id,
        amount_paid,
        ROW_NUMBER() OVER (
            PARTITION BY person_id
            ORDER BY amount_paid DESC, entry_time DESC, product_name
        ) AS rn
    FROM paid_strong_start
),


club AS
(
    SELECT
        club_name,
        COUNT(*)         AS club_total,
        SUM(amount_paid) AS gross_sales_club
    FROM chosen
    WHERE rn = 1
    GROUP BY club_name
),


club_members AS
(
    SELECT
        c.shortname AS club_name,
        COUNT(DISTINCT (p.center || 'p' || p.id)) AS club_member_base
    FROM persons p
    JOIN centers c
      ON c.id = p.center
    WHERE
        p.status = 1
        AND p.center IN (:Scope)
    GROUP BY c.shortname
)

SELECT
    ch.club_name    AS "Club Name",
    ch.product_name AS "Product Name",
    COUNT(*)        AS "Signups",

    c.club_total       AS "Club Total",
    c.gross_sales_club AS "Gross Sales $ (Club)",

    cm.club_member_base AS "Club Member Base",

    100.0 * c.club_total / NULLIF(cm.club_member_base, 0)
        AS "% Participation (Club)"

FROM chosen ch
JOIN club c
  ON c.club_name = ch.club_name
JOIN club_members cm
  ON cm.club_name = ch.club_name

WHERE ch.rn = 1

GROUP BY
    ch.club_name,
    ch.product_name,
    c.club_total,
    c.gross_sales_club,
    cm.club_member_base

ORDER BY
    "% Participation (Club)" DESC,
    c.club_total DESC,
    c.gross_sales_club DESC,
    ch.club_name,
    "Signups" DESC;
