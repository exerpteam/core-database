-- This is the version from 2026-02-05
--  
SELECT
    pr.globalid                AS cc_stock_item_id
    ,pr.center                 AS exerp_center_id
    , pr.center||'prod'||pr.id AS exerp_product_id
    , CASE
        WHEN pr.PTYPE = 1
        THEN 'RETAIL'
        WHEN pr.PTYPE = 2
        THEN 'SERVICE'
        WHEN pr.PTYPE = 4
        THEN 'CLIPCARD'
        WHEN pr.PTYPE = 5
        THEN 'JOINING_FEE'
        WHEN pr.PTYPE = 6
        THEN 'TRANSFER_FEE'
        WHEN pr.PTYPE = 7
        THEN 'FREEZE_PERIOD'
        WHEN pr.PTYPE = 8
        THEN 'GIFTCARD'
        WHEN pr.PTYPE = 9
        THEN 'FREE_GIFTCARD'
        WHEN pr.PTYPE = 10
        THEN 'SUBS_PERIOD'
        WHEN pr.PTYPE = 12
        THEN 'SUBS_PRORATA'
        WHEN pr.PTYPE = 13
        THEN 'ADDON'
        WHEN pr.PTYPE = 14
        THEN 'ACCESS'
        ELSE 'UNKNOWN'
    END AS exerp_product_type 
    , CASE st.ST_TYPE
        WHEN 0
        THEN 'CASH'
        WHEN 1
        THEN 'EFT'
    END subscription_deduction_type
FROM
    products pr
LEFT JOIN 
    subscriptiontypes st 
ON 
    st.center = pr.center 
AND st.id = pr.id