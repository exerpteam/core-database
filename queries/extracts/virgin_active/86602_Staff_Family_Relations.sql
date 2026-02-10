-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
     c2.id                      AS "Club_Socio",
     p2.FULLNAME                AS "Fullname_Socio",
     p2.CENTER || 'p' || p2.ID  AS "Person_ID",
     s2.CENTER || 'ss' || s2.ID AS "Subscription_ID",
     prod2.name                 AS "Sub_Name",
     s2.START_DATE              AS "Start_Date_Sub",
     s2.END_DATE                AS "End_Date_Sub",
      (CASE  s2.STATE  
		WHEN 2 THEN 'ACTIVE'  
		WHEN 3 THEN 'ENDED'  
		WHEN 4 THEN 'FROZEN'  
		WHEN 7 THEN 'WINDOW'  
		WHEN 8 THEN 'CREATED' 
		ELSE 'UNKNOWN' 
	 END)                       AS "Subscription_State",
     c1.id                      AS "Club_Staff",
     --s1.CENTER || 'ss' || s1.ID AS "Subscription_ID_Staff",
     p1.FULLNAME                AS "Fullname_Staff",
     p1.CENTER || 'p' || p1.ID  AS "Person_ID",
	 rel.RTYPE					AS "Relation_Type",
	 rel.STATUS					AS "Relation_Status"
 FROM
     RELATIVES rel
 JOIN
     PERSONS p2
 ON
     p2.CENTER = rel.CENTER
     AND p2.ID = rel.ID
 JOIN
     CENTERS c2
 ON
     c2.id = p2.center
 LEFT JOIN
     SUBSCRIPTIONS s2
 ON
     s2.OWNER_CENTER = p2.CENTER
     AND s2.OWNER_ID = p2.ID
     AND s2.STATE IN (2,4,8)
 LEFT JOIN 
    SUBSCRIPTIONTYPES st2
 ON 
    s2.SubscriptionType_Center = st2.Center 
    AND S2.SubscriptionType_ID = st2.ID 
 LEFT JOIN 
    products prod2
 ON
    St2.Center = Prod2.Center 
    AND St2.Id = Prod2.Id 
-- LEFT JOIN
--     PERSON_EXT_ATTRS atts2
-- ON
--     atts2.PERSONCENTER = p2.CENTER
--     AND atts2.PERSONID = p2.ID
--     AND atts2.NAME = 'CREATION_DATE'
JOIN
     PERSONS p1
 ON
     p1.CENTER = rel.RELATIVECENTER
     AND p1.ID = rel.RELATIVEID
 JOIN
     CENTERS c1
 ON
     c1.id = p1.center
 LEFT JOIN
     SUBSCRIPTIONS s1
 ON
     s1.OWNER_CENTER = p1.CENTER
     AND s1.OWNER_ID = p1.ID
     AND s1.STATE IN (2,4,8)
 WHERE
     rel.RTYPE = 1
     AND rel.STATUS = 1
     AND p2.center in ($$scope$$)
     AND prod2.name in ('Staff Family', 'Staff Family Senior', 'Staff Family Young')
     --and s2.START_DATE between (from_date) and (to_date)