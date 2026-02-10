-- The extract is extracted from Exerp on 2026-02-08
-- Used for the 15% off - copy of Addon by scope
 SELECT distinct
         sa.SUBSCRIPTION_CENTER ||'ss'|| sa.SUBSCRIPTION_id as main_subscription,
     p.center ||'p'|| p.id as memberid,
     p.center as owner_center,
         sa.center_id                                                              as add_on_scope,
     prod.name                                    AS add_on_name,
    sa.id as "Subscription add-on key",
     sa.ADDON_PRODUCT_ID,
     sa.START_DATE,
     sa.END_DATE,
     sa.INDIVIDUAL_PRICE_PER_UNIT,
     sa.EMPLOYEE_CREATOR_CENTER ||'emp'|| sa.EMPLOYEE_CREATOR_ID as add_on_creater_id,
     p.firstname,
     p.lastname,
     p.Address1|| ' ' ||p.Address2 AS address,
     p.zipcode,
     p.city
                 FROM
             SUBSCRIPTION_ADDON sa
                 left join centers sa_c on sa_c.id = sa.CENTER_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.CENTER = sa.SUBSCRIPTION_CENTER
             AND s.ID = sa.SUBSCRIPTION_ID
         JOIN
             PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
 left JOIN masterproductregister m
 ON
     sa.addon_product_id = m.id
 LEFT JOIN products prod
 ON
     m.globalid = prod.globalid
 left JOIN subscription_sales ss
 ON
     sa.subscription_center = ss.subscription_center
 AND sa.subscription_id= ss.subscription_id
 where
  p.center  in (:scope)
 and sa.cancelled = 0
 and prod.name like '%PT by DD%'
 and sa.center_id in
         (76,29,437,33,35,27,421,405,38,438,40,39,48,12,51,9,56,954,57,415,2,60,61,422,452,6,69,410,16,75,953,425,408)
