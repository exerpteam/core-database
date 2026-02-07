 SELECT
     ss.owner_center||'p'||ss.owner_id             AS customer,
         ss.owner_center as owner_center,
         sa.center_id                                                              as add_on_scope,
     prod.name                                    AS add_on_name,
     sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as main_subscription,
     sa.id as "Subscription add-on key",
     sa.ADDON_PRODUCT_ID,
     sa.START_DATE,
    longtodate(sa.CREATION_TIME) as salestime,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     per.firstname,
     per.lastname,
     per.Address1|| ' ' ||per.Address2 AS adress,
     per.zipcode,
     per.city
 FROM
     SUBSCRIPTION_ADDON sa
 JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
 LEFT JOIN products prod
 ON
     m.globalid = prod.globalid
 JOIN subscription_sales ss
 ON
     sa.subscription_center = ss.subscription_center
 AND sa.subscription_id= ss.subscription_id
 JOIN subscriptions s
 ON
     ss.owner_center = s.owner_center
 AND ss.owner_id = s.owner_id
 JOIN persons per
 ON
     per.center = s.owner_center
 AND per.id = s.owner_id
 WHERE
     ss.owner_center  in (:scope)
 and sa.cancelled = 0
 -- AND sa.INDIVIDUAL_PRICE_PER_UNIT > 0
 and sa.EMPLOYEE_CREATOR_ID != 2221
 and prod.name like '%PT by DD%'
 and sa.CREATION_TIME > 1598918399000
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
     sa.CREATION_TIME,
     sa.id,
     sa.SUBSCRIPTION_CENTER,
     sa.SUBSCRIPTION_id,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     sa.START_DATE
 ORDER BY
     ss.owner_center,
     ss.owner_id
