-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    d.club_name      AS "Club Name",
    d.person_id      AS "PersonID",
    d.product_name   AS "Product Name",
    d.member_type    AS "Member Type",
    d.amount_paid    AS "Sale Amount",
    d.sale_date      AS "Sale Date"
FROM
(
    WITH params AS
    (
        SELECT
            datetolongC('2025-12-01 00:00', c.id) AS FromDate,
            c.id AS center_id,
            datetolongC(
                TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI'),
                c.id
            ) AS ToDate
        FROM centers c
    ),

    base AS
    (
        SELECT
            c.shortname AS club_name,
            (p.center || 'p' || p.id) AS person_id,
            pro.name AS product_name,
            COALESCE(inv.total_amount, 0) AS amount_paid,
            CAST(longtodatec(t.entry_time, t.center) AS DATE) AS sale_date,
            t.entry_time AS entry_time,

            CASE
                WHEN p.first_active_start_date >= CAST(longtodatec(t.entry_time, t.center) AS DATE)
                THEN 'New Member'
                ELSE 'Existing Member'
            END AS member_type
        FROM persons p
        JOIN clipcards cc
            ON cc.owner_center = p.center
           AND cc.owner_id     = p.id
        JOIN centers c
            ON c.id = p.center
        JOIN products pro
            ON pro.center = cc.center
           AND pro.id     = cc.id
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
            base.*,
            ROW_NUMBER() OVER (
                PARTITION BY base.person_id
                ORDER BY base.amount_paid DESC, base.entry_time DESC, base.product_name
            ) AS rn
        FROM base
    )

    SELECT
        club_name,
        person_id,
        product_name,
        member_type,
        amount_paid,
        sale_date
    FROM chosen
    WHERE rn = 1
) d
ORDER BY
    d.club_name,
    d.sale_date DESC,
    d.person_id;
