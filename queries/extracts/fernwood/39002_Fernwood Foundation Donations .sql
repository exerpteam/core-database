WITH
params AS
(
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
SELECT
    c.shortname AS "Club Name",
    prod.name AS "Donation Product",
    COUNT(*) AS "Number of Donations",
    SUM(COALESCE(invl.total_amount, sao.individual_price_per_unit, 0)) AS "Total Donation Value"
FROM
    centers c
JOIN
    params p ON p.CENTER_ID = c.id
-- Get donations from Subscription Add-ons
LEFT JOIN
    subscription_addon sao
    ON sao.center_id = c.id
    AND sao.creation_time BETWEEN p.FromDate AND p.ToDate
    AND sao.cancelled = 'false'
LEFT JOIN
    masterproductregister mpr_addon
    ON mpr_addon.id = sao.addon_product_id
LEFT JOIN
    products prod_addon
    ON prod_addon.center = sao.center_id
    AND prod_addon.globalid = mpr_addon.globalid
    AND prod_addon.name IN (
        'Fernwood Foundation Donation - $1',
        'Fernwood Foundation Donation - $2',
        'Fernwood Foundation Donation'
    )
-- Get donations from Services/Clipcards
LEFT JOIN
    invoices inv
    ON inv.center = c.id
    AND inv.trans_time BETWEEN p.FromDate AND p.ToDate
LEFT JOIN
    invoice_lines_mt invl
    ON invl.center = inv.center
    AND invl.id = inv.id
LEFT JOIN
    products prod_service
    ON prod_service.center = invl.productcenter
    AND prod_service.id = invl.productid
    AND prod_service.name IN (
        'Fernwood Foundation Donation - $1',
        'Fernwood Foundation Donation - $2',
        'Fernwood Foundation Donation'
    )
-- Combine product names from both sources
CROSS JOIN LATERAL (
    SELECT COALESCE(prod_addon.name, prod_service.name) AS name
) prod
WHERE
    c.id IN (:Scope)
    AND (prod_addon.name IS NOT NULL OR prod_service.name IS NOT NULL)
GROUP BY
    c.shortname,
    prod.name
ORDER BY
    c.shortname,
    prod.name;