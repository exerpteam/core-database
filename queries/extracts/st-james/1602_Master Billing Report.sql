-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9693
WITH
    PARAMS AS
    (   SELECT
            CAST($$from_date$$ AS DATE)                               AS FROM_DATE,
            CAST($$to_date$$ AS DATE)                               AS TO_DATE,
            (CAST($$to_date$$ AS DATE) - CAST($$from_date$$ AS DATE)) + 1 AS days_between,
            id                                                  AS center
        FROM
            centers
        WHERE
            ID IN ($$Scope$$)
    )
, free_days as (
SELECT
    sf.subscription_center,
    sf.subscription_id,
    SUM(params.days_between-(LEAST(sf.end_date,params.to_date)+1- 
    GREATEST(sf.start_date, params.from_date))) as charged_days
FROM
    subscription_reduced_period sf
JOIN    
    params
ON
    params.center = sf.subscription_center
WHERE
    sf.start_date <= params.TO_DATE
AND sf.end_date >= params.FROM_DATE
AND sf.state = 'ACTIVE'
GROUP BY
    sf.subscription_center,
    sf.subscription_id
)    
SELECT
    s.owner_center||'p'||s.owner_id as "Member ID",
    s.center||'ss'||s.id as "Subscription ID",
    pr.name "Product Name",
    'Membership Fee'     AS "Price Type",
    CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State",    
    s.subscription_price AS "Unit Price",
    COALESCE(fd.charged_days, params.days_between) as "Billable Days",
    params.days_between - COALESCE(fd.charged_days, params.days_between) as "Frozen Days",
    ROUND(COALESCE(fd.charged_days, params.days_between) * (s.subscription_price / params.days_between),2) as "Period Price"
FROM
    PARAMS
JOIN
    subscriptions s
ON
    params.center = s.center
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND ((st.st_type = 1 AND ($$selected$$ = 'NO'))  OR  (st.st_type = 2))      
JOIN
    PRODUCTS pr
ON
    pr.center = st.center
AND pr.id = st.id
LEFT JOIN 
    free_days fd
ON
    s.center  = fd.subscription_center 
    AND s.id = fd.subscription_id
WHERE
    s.start_date <= params.from_date
AND 
    ( 
        s.end_date >= params.to_date 
    OR  s.end_date IS NULL)
AND s.subscription_price > 0
 
UNION ALL
 
SELECT
    s.owner_center||'p'||s.owner_id as "Member ID",
    s.center||'ss'||s.id as "Subscription ID",
    CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State",
    pr.name,
    'Addon Fee',
    sa.individual_price_per_unit,
    COALESCE(fd.charged_days, params.days_between) as no_of_days,
    params.days_between - COALESCE(fd.charged_days, params.days_between) as "Frozen Days",    
    ROUND(COALESCE(fd.charged_days, params.days_between)*(sa.individual_price_per_unit/params.days_between),2) as period_price
FROM
    PARAMS
JOIN
    subscriptions s
ON
    s.center = params.center
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND ((st.st_type = 1 AND ($$selected$$ = 'NO'))  OR  (st.st_type = 2))   
JOIN
    subscription_addon sa
ON
    s.center = sa.subscription_center
AND s.id = sa.subscription_id
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS pr
ON
    pr.center = sa.CENTER_ID
AND pr.GLOBALID = mpr.GLOBALID
LEFT JOIN 
    free_days fd
ON
    s.center  = fd.subscription_center 
    AND s.id = fd.subscription_id
WHERE
    sa.start_date <= params.from_date
AND 
    ( 
        sa.end_date >= params.to_date 
    OR  sa.end_date IS NULL)
AND NOT sa.cancelled
AND sa.individual_price_per_unit > 0
