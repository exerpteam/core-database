-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
scope_centers AS (
    SELECT id, shortname
    FROM centers
    WHERE id IN (:Scope)
),

params AS (
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), sc.id) AS FromDate,
        sc.id AS center_id,
        CAST(
            (
                datetolongC(
                    TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),
                    sc.id
                ) - 1
            ) AS BIGINT
        ) AS ToDate
    FROM scope_centers sc
),

donation_names AS (
    SELECT unnest(ARRAY[
        'Fernwood Foundation Donation - $1',
        'Fernwood Foundation Donation - $2',
        'Fernwood Foundation Donation'
    ]) AS name
),

/* 1) Add-on donations (link to subscription to get the person) */
addon_donations AS (
    SELECT
        sao.center_id AS center_id,
        s.person_id   AS person_id,
        prod_addon.name AS product_name,
        1 AS donation_count,
        COALESCE(sao.individual_price_per_unit, 0) AS amount
    FROM params p
    JOIN subscription_addon sao
      ON sao.center_id = p.center_id
     AND sao.creation_time BETWEEN p.FromDate AND p.ToDate
     AND sao.cancelled = 'false'
    JOIN subscriptions s
      ON s.center = sao.center_id
     AND s.id     = sao.subscription_id
    JOIN masterproductregister mpr_addon
      ON mpr_addon.id = sao.addon_product_id
    JOIN products prod_addon
      ON prod_addon.center   = sao.center_id
     AND prod_addon.globalid = mpr_addon.globalid
    JOIN donation_names dn
      ON dn.name = prod_addon.name
),

/* 2) Invoice/clipcard donations */
service_donations AS (
    SELECT
        inv.center AS center_id,
        COALESCE(inv.person_id, inv.person) AS person_id,
        prod_service.name AS product_name,
        1 AS donation_count,
        COALESCE(invl.total_amount, 0) AS amount
    FROM params p
    JOIN invoices inv
      ON inv.center = p.center_id
     AND inv.trans_time BETWEEN p.FromDate AND p.ToDate
    JOIN invoice_lines_mt invl
      ON invl.center = inv.center
     AND invl.id     = inv.id
    JOIN products prod_service
      ON prod_service.center = invl.productcenter
     AND prod_service.id     = invl.productid
    JOIN donation_names dn
      ON dn.name = prod_service.name
),

all_donations AS (
    SELECT * FROM addon_donations
    UNION ALL
    SELECT * FROM service_donations
)

SELECT
    sc.shortname   AS "Club Name",
    d.person_id    AS "Person ID",
    pe.fullname    AS "Member Name",
    d.product_name AS "Donation Product",
    SUM(d.donation_count) AS "Number of Donations",
    SUM(d.amount)         AS "Total Donation Value"
FROM all_donations d
JOIN scope_centers sc
  ON sc.id = d.center_id
LEFT JOIN persons pe
  ON pe.id = d.person_id
GROUP BY
    sc.shortname,
    d.person_id,
    pe.fullname,
    d.product_name
ORDER BY
    sc.shortname,
    d.product_name,
    pe.fullname;
