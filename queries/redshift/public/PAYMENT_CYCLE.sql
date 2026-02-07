SELECT
    id   AS "ID",
    name AS "NAME",
    CASE company
        WHEN true
        THEN 'COMPANY'
        ELSE 'PERSON'
    END AS "CUSTOMER_TYPE",
    CASE scope_type
        WHEN 'T'
        THEN 'GLOBAL'
        WHEN 'A'
        THEN 'AREA'
        WHEN 'C'
        THEN 'CENTER'
        ELSE 'UNDEFINED'
    END  AS "SCOPE_TYPE",
    scope_id AS "SCOPE_ID" ,
    CASE renewal_policy
        WHEN 1
        THEN 'CASH'
        WHEN 2
        THEN '2 MONTH PREPAID'
        WHEN 3
        THEN 'NEVER'
        WHEN 4
        THEN 'POSTPAID'
        WHEN 5
        THEN 'PREPAID'
        WHEN 6
        THEN 'ROLLING POSTPAID'
        WHEN 7
        THEN 'ROLLING PREPAID'
        WHEN 8
        THEN 'MID-MONTH'
        WHEN 9
        THEN 'DAILY ROLLING'
        WHEN 10
        THEN 'DAILY POSTPAID ROLLING'
        ELSE 'OTHER'
    END AS "RENEWAL_POLICY"                       
FROM
    payment_cycle_config