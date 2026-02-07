select --distinct
        mp.cached_productname AS "Product Name"
        ,mp.globalid AS "Global ID"
        ,CASE
                WHEN mp.recurring_clipcard_id is not null then 'Yes' 
                ELSE 'No'
        END AS "Recurring Clipcard"
        ,CASE
                WHEN  mp.cached_producttype = 1 THEN 'Goods'
                WHEN  mp.cached_producttype = 2 THEN 'Service'
                WHEN  mp.cached_producttype = 4 THEN 'Clipcard'
                WHEN  mp.cached_producttype = 5 THEN 'Subscription creation'
                WHEN  mp.cached_producttype = 6 THEN 'Transfer'
                WHEN  mp.cached_producttype = 7 THEN 'Freeze period'
                WHEN  mp.cached_producttype = 8 THEN 'Gift card'
                WHEN  mp.cached_producttype = 9 THEN 'Free gift card'
                WHEN  mp.cached_producttype = 10 THEN 'Subscription'
                WHEN  mp.cached_producttype = 12 THEN 'Subscription pro-rata'
                WHEN  mp.cached_producttype = 13 THEN 'Subscription add-on'
                WHEN  mp.cached_producttype = 14 THEN 'Access product'
        ELSE 'Other'
        END AS "Product Type"
		,*
from fernwood.masterproductregister mp
order by 4,1