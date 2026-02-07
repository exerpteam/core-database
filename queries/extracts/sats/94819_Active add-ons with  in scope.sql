SELECT
per.external_id,
     ss.owner_center||'p'||ss.owner_id             AS "Member ID",
     prod2.name as "SUBSCRIPTION_NAME",
      sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as "Subscription key",
         ss.owner_center as subscription_center,
         sa.id as "Subscription add-on key" ,
          prod.name                                    AS ADD_ON_NAME,
          prod.globalid,
          sa.center_id                                                              as add_on_scope,
     sa.ADDON_PRODUCT_ID,
     sa.START_DATE,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT
    
   
 FROM
     SUBSCRIPTION_ADDON sa
 JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
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
and per.center in (:scope)
and s.state in (2,4,8)
 --AND sa.INDIVIDUAL_PRICE_PER_UNIT > 0
and  ((sa.END_DATE is null) or (sa.END_DATE > current_timestamp)) 

 GROUP BY
         per.center,
         per.id,
     ss.owner_center,
     ss.owner_id,
         sa.center_id,
     sa.cancelled,
     prod.name,
     per.firstname,
     per.lastname,
     per.Address1,
     per.Address2,
     per.zipcode,
     per.city,
     sa.ADDON_PRODUCT_ID,
     sa.END_DATE,
     sa.id,
     sa.SUBSCRIPTION_CENTER,
     sa.SUBSCRIPTION_id,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     sa.START_DATE,
prod2.name,
prod.globalid
 ORDER BY
     ss.owner_center,
     ss.owner_id