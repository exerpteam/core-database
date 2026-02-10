-- The extract is extracted from Exerp on 2026-02-08
--  
     SELECT DISTINCT
    s.CENTER ||'ss'|| s.id as main_subscription,
     p.center ||'p'|| p.id as memberid,
     s.center ||'ss'|| s.id as mainsubscription_id,
     p.center as owner_center,
     c.name as owner_centername,
         s.center                                                             as add_on_scope,
     c.name as add_on_centername,
     prod.name                                    AS add_on_name,
  --  sa.id as "Subscription add-on key",
   --  sa.ADDON_PRODUCT_ID,
     s.START_DATE,
     s.END_DATE,
     s.subscription_price,
     s.creator_center ||'emp'|| s.creator_ID as add_on_creater_id,
 longtodate(s.CREATION_TIME) as addoncreator_time,
     p.firstname
         FROM   
           SUBSCRIPTIONS s
           join SUBSCRIPTIONTYPES st
           ON
    s.SubscriptionType_Center = st.Center
AND s.SubscriptionType_ID = st.ID
and st.st_type in (2)
        
         left join centers sa_c on sa_c.id = s.CENTER    
         JOIN
            PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
         
         JOIN
             CENTERS c
         ON
             c.ID = p.CENTER
         LEFT JOIN
             PERSONS m
         ON
             m.CENTER = c.MANAGER_CENTER
             AND m.ID = c.MANAGER_ID
         JOIN
    Products prod
ON
    st.Center = prod.Center
AND st.Id = prod.Id
      
         WHERE
         p.center  in (:scope)
 and
  s.center  in (76,29,437,33,35,27,421,405,38,438,40,39,48,12,51,9,56,954,57,415,2,60,61,422,452,6,69,410,16,75,953,425,408)
-- and sa.cancelled = 0
 and prod.name like '%PT by DD%'