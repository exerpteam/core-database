-- The extract is extracted from Exerp on 2026-02-08
-- 
WITH
params AS
(
    SELECT
        /*+ materialize */
        datetolongC(TO_CHAR(CAST(:StartDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:EndDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
    FROM
        centers c
)
SELECT DISTINCT
    p.center || 'p' || p.id AS "Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name", 
    cc.code AS "Campaign Code",
    c.id AS "Centre ID",
    c.name AS "Centre Name",
    CAST(longtodatec(pu.use_time, pu.person_center) as date) AS "Date Used",
    COALESCE(prod.name, subprod.name, 'Unknown Product') AS "Product Purchased",
    COALESCE(invl.total_amount, sp.price, 0) AS "Product Amount"
FROM 
    campaign_codes cc
JOIN 
    privilege_usages pu 
    ON pu.campaign_code_id = cc.id
JOIN
    persons p
    ON p.center = pu.person_center
    AND p.id = pu.person_id
JOIN
    centers c
    ON c.id = p.center
JOIN
    params
    ON params.CENTER_ID = pu.person_center
-- Get product information from subscriptions
LEFT JOIN 
    subscription_price sp 
    ON sp.id = pu.target_id
    AND pu.target_service = 'SubscriptionPrice'
LEFT JOIN 
    subscriptions s 
    ON s.center = sp.subscription_center 
    AND s.id = sp.subscription_id
LEFT JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id                
LEFT JOIN
    products subprod
    ON subprod.center = st.center
    AND subprod.id = st.id
-- Get product information from invoice lines
LEFT JOIN 
    invoice_lines_mt invl 
    ON invl.center = pu.target_center
    AND invl.id = pu.target_id
    AND invl.subid = pu.target_subid
    AND pu.target_service = 'InvoiceLine'
LEFT JOIN
    products prod
    ON prod.center = invl.productcenter
    AND prod.id = invl.productid
WHERE
    UPPER(cc.code) = 'FREE21'
    AND pu.use_time BETWEEN params.FromDate AND params.ToDate
    AND p.center IN (:Scope)
ORDER BY 
    c.name, p.lastname, p.firstname