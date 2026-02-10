-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS MATERIALIZED
(
        SELECT
                datetolongc(TO_CHAR(TO_DATE(:fromDate , 'YYYY-MM-dd'), 'YYYY-MM-dd'),c.id) AS fromDate,
                datetolongc(TO_CHAR(TO_DATE(:toDate , 'YYYY-MM-dd') + interval '1 days', 'YYYY-MM-dd'),c.id)-1 AS toDate,
                c.id AS center_id
        FROM vivagym.centers c
        WHERE
                c.country = 'ES'
)
SELECT
        pu.PERSON_CENTER || 'p' || pu.PERSON_ID AS PID, 
        sc.NAME AS CampaignName,
        cc.CODE AS Code,
        longtodatec(pu.USE_TIME, pu.person_center) as UseTime,
        pu.state AS priv_usage_state,
        pu.source_globalid,
        pu.source_center,
        pu.source_id,
        pu.source_subid,
        pu.target_service,
        pu.target_center,
        pu.target_id,
        pu.target_subid,
        pu.privilege_type,
        (CASE
                WHEN  pu.target_service IN ('InvoiceLine')
                        THEN prod.name
                WHEN  pu.target_service IN ('SubscriptionPrice')
                        THEN prod2.name
                ELSE NULL
        END) AS product_name,
        sp.price AS campaign_subscriptionPrice,
        (CASE s.state 
                WHEN 2 THEN 'ACTIVE' 
                WHEN 3 THEN 'ENDED' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE 'Undefined' 
        END) AS subscription_state
FROM vivagym.campaign_codes cc
JOIN vivagym.startup_campaign sc ON sc.id = cc.campaign_id AND cc.campaign_type = 'STARTUP'
JOIN vivagym.privilege_usages pu ON pu.campaign_code_id = cc.id AND pu.target_service IN ('InvoiceLine','SubscriptionPrice') AND pu.privilege_type = 'PRODUCT'
JOIN params par ON pu.person_center = par.center_id
LEFT JOIN vivagym.invoice_lines_mt invl ON invl.center = pu.target_center AND invl.id = pu.target_id AND invl.subid = pu.target_subid AND pu.target_service IN ('InvoiceLine')
LEFT JOIN vivagym.subscription_price sp ON sp.id = pu.target_id AND pu.target_service = 'SubscriptionPrice'
LEFT JOIN vivagym.products prod ON invl.productcenter = prod.center AND invl.productid = prod.id
LEFT JOIN vivagym.subscriptions s ON s.center = sp.subscription_center AND s.id = sp.subscription_id
LEFT JOIN vivagym.products prod2 ON s.subscriptiontype_id = prod2.id AND s.subscriptiontype_center = prod2.center
WHERE
        pu.use_time BETWEEN par.fromDate AND par.toDate
        AND cc.code IN (:campaingnames)