SELECT DISTINCT
	 s.OWNER_CENTER AS CLUB,
     s.OWNER_CENTER||'p'|| s.OWNER_ID                                                                                                                                                             AS MEMBER_ID,
      CASE  per.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest'  WHEN 9 THEN  'Child'  WHEN 10 THEN  'External_Staff' ELSE 'Unknown' END AS PERSON_STATE,
     p.NAME                                                                                                                                                                                       AS SUBSCRIPTION_NAME,
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END                                                                                                       AS SUBSCRIPTION_STATE,
     s.START_DATE                                                                                                                                                                                 AS SUBSCRIPTION_START_DATE,
     mpr.CACHED_PRODUCTNAME                                                                                                                                                                       AS ADD_ON_NAME,
     sa.START_DATE                                                                                                                                                                                AS ADD_ON_START_DATE,
     sa.END_DATE                                                                                                                                                                                AS ADD_ON_END_DATE,
     a.name
,a.ROOT_AREA
 FROM
     SUBSCRIPTIONS s
JOIN CENTERS c
ON c.ID = s.OWNER_CENTER AND c.COUNTRY = 'IT'
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.center = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PRODUCTS p
 ON
     p.center = st.center
     AND p.id = st.id
 LEFT JOIN
     SUBSCRIPTION_ADDON sa
 ON
     sa.SUBSCRIPTION_CENTER = s.center
     AND sa.SUBSCRIPTION_ID = s.id
 LEFT JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.id= sa.ADDON_PRODUCT_ID
 LEFT JOIN
     PERSONS per
 ON
     per.center = s.OWNER_CENTER
     AND per.id = s.OWNER_ID
 LEFT JOIN
     AREA_CENTERS ac
 ON
     ac.center = per.center
 LEFT JOIN
     areas a
 ON
     a.id = ac.area
 WHERE

 s.state IN (2, 4, 8) -- ACTIVE, FROZEN, CREATED
    AND p.PRIMARY_PRODUCT_GROUP_ID IN 
	(
		'5408'
	)
AND p.NAME = 'Open 12 Mesi Collection PRESALES CASH'


