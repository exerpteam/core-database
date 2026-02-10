-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     ss.owner_center||'p'||ss.owner_id             AS customer,
         ss.owner_center as owner_center,
         sa.center_id                                                              as add_on_scope,
     prod.name                                    AS add_on_name,
     sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as main_subscription,
prod2.name,
     sa.id,
     sa.ADDON_PRODUCT_ID,
     sa.START_DATE,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     per.firstname,
     per.lastname,
     per.Address1|| ' ' ||per.Address2 AS adress,
     per.zipcode,
     per.city,
     Emails.TxtValue AS Email
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


 LEFT JOIN Person_Ext_Attrs Emails
 ON
     per.center = Emails.PersonCenter
 AND per.id = Emails.PersonId
 AND Emails.Name = '_eClub_Email'
 WHERE
  --   ss.owner_center  in (scope)and
 sa.cancelled = 0
 and prod.name = 'Free Child care Premium'
and (s.center,s.id) in (:members)
and s.state in (2,4)
 --AND sa.INDIVIDUAL_PRICE_PER_UNIT > 0

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
     Emails.TxtValue,
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
