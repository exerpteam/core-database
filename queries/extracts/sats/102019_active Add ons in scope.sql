-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
             
             TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') AS todaysDate,
                      c.ID AS CenterID
                FROM
                        centers c
                where
            c.id  in (:scope)     
)


 SELECT
     ss.owner_center||'p'||ss.owner_id             AS customer,
         ss.owner_center as owner_center,
         sa.center_id                                                              as add_on_scope,
     prod.name                                    AS add_on_name,
     sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as main_subscription,
prod2.name,
     sa.id as "Add-on ID",
     sa.ADDON_PRODUCT_ID ,
     sa.START_DATE,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT
 FROM
     SUBSCRIPTION_ADDON sa
 JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
join params
on
sa.subscription_center = params.CenterID

     
LEFT JOIN products prod
 ON
     m.globalid = prod.globalid
left JOIN subscription_sales ss
 ON
     sa.subscription_center = ss.subscription_center
 AND sa.subscription_id= ss.subscription_id
left JOIN subscriptions s
 ON
     ss.owner_center = s.owner_center
 AND ss.owner_id = s.owner_id
left JOIN persons per
 ON
     per.center = s.owner_center
 AND per.id = s.owner_id
left JOIN SubscriptionTypes st
                 ON 
                 s.SubscriptionType_Center =  st.Center
                 AND  S.SubscriptionType_ID=  St.ID
 
                 JOIN Products prod2
                 ON st.Center = prod2.Center AND  st.Id = Prod2.Id

 
 WHERE
 
 sa.cancelled = 0
and s.state in (2,4)
and ( (sa.END_DATE > todaysDate) or (sa.END_DATE is null))
 --AND sa.INDIVIDUAL_PRICE_PER_UNIT > 0

 GROUP BY
         per.center,
         per.id,
     ss.owner_center,
     ss.owner_id,
         sa.center_id,
     sa.cancelled,
     prod.name,
     sa.ADDON_PRODUCT_ID,
     sa.END_DATE,
     sa.id,
     sa.SUBSCRIPTION_CENTER,
     sa.SUBSCRIPTION_id,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     sa.START_DATE,
prod2.name
 ORDER BY
     ss.owner_center,
     ss.owner_id