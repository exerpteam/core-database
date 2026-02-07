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
 FROM
     SUBSCRIPTIONS s
JOIN CENTERS c
ON c.ID = s.OWNER_CENTER AND c.COUNTRY = 'IT'
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.center = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
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
 JOIN
     PERSONS per
 ON
     per.center = s.OWNER_CENTER
     AND per.id = s.OWNER_ID
 JOIN
     AREA_CENTERS ac
 ON
     ac.center = per.center
 JOIN
     areas a
 ON
     a.id = ac.area
     AND a.ROOT_AREA = 1
 WHERE
--	(
--        mpr.PRIMARY_PRODUCT_GROUP_ID IN (20005,20004,34802)
--		OR sa.id IS NULL
--	)
--	AND
 s.state IN (2, 4, 8) -- ACTIVE, FROZEN, CREATED
    AND p.PRIMARY_PRODUCT_GROUP_ID IN 
	(
		'4601'
		,'5213'
		,'5216'
		,'5217'
		,'5220'
		,'5229'
		,'5231'
		,'5232'
		,'5233'
		,'5234'
		,'5237'
		,'5240'
		,'5402'
		,'5403'
		,'5405'
		,'5408'
		,'5409'
		,'5410'
		,'5412'
		,'5415'
		,'6802'
		,'11403'
		,'11602'
		,'20006'
		,'20007'
		,'20009'
		,'20019'
		,'20402'
		,'20406'
		,'20409'
		,'20413'
		,'20601'
		,'20802'
		,'20804'
		,'20805'
		,'20806'
		,'22602'
		,'25201'
		,'27601'
		,'27803'
		,'32001'
		,'35401'
		,'35601'
		,'35801'
		,'36006'
		,'36406'
		,'36603'
		,'38001'
		,'40002'
		,'40401'
		,'40603'
	)
--AND (sa.CANCELLED = 'false' OR sa.CANCELLED IS NULL)
--AND (sa.START_DATE IS NULL OR sa.END_DATE IS NULL OR CAST(current_date as date) BETWEEN CAST(sa.START_DATE as date) AND --CAST(sa.END_DATE as date))