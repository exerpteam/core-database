-- The extract is extracted from Exerp on 2026-02-08
-- 09.01.25 -RG: Created for Ebbie as part of SR-320051
 SELECT
	
	
	--ssec.CENTER || 'ss' || ssec.ID,
     --CASE rel.RTYPE WHEN 1 THEN 'FRIEND' WHEN 4 THEN 'FAMILY' ELSE 'UNKNOWN - Contact Exerp support' END INVALID_RELATIONSHIP,
     --rel.STATUS RELATION_STATUS,
	 cp.shortname Buddy_Club,
     rel.CENTER || 'p' || rel.ID "Buddy 50% ID",
	 prod.NAME Buddy_Sub,
	 ssec.SUBSCRIPTION_PRICE Buddy_price,
     pp.FULLNAME Buddy_Name,
	 ssec.BINDING_END_DATE Buddy_Binding_End_Date,
	 pp.Birthdate Buddy_Birthdate,
	 email.TXTVALUE Buddy_Email,
	 pp.address1 Buddy_address1,
	 pp.address2 Buddy_address2,
	 pp.address3 Buddy_address3,
	 pp.City Buddy_City,
	 pp.Country Buddy_Country,
	 pp.Zipcode Buddy_postcode,
	 
     --pp.LASTNAME PRIMARY_LASTNAME,
     --cp.NAME PRIMARY_HOME_CLUB,
	 cs.Shortname Main_Member_Club,
     rel.RELATIVECENTER || 'p' || rel.RELATIVEID Main_Member_ID,
     ps.FULLNAME Main_Member_NAME

 FROM
     RELATIVES rel
 join PERSONS pp on pp.CENTER = rel.CENTER and pp.ID  = rel.ID
 left join PERSON_EXT_ATTRS email ON pp.center = email.PERSONCENTER AND pp.ID = email.PERSONID AND email.NAME = '_eClub_Email'
 join PERSONS ps on ps.CENTER = rel.RELATIVECENTER and ps.ID  = rel.RELATIVEID
 join CENTERS cp on cp.ID = pp.CENTER
 join CENTERS cs on cs.ID = ps.CENTER
 JOIN SUBSCRIPTIONS ssec ON
     ssec.OWNER_CENTER = rel.CENTER
     AND ssec.OWNER_ID = rel.ID
     AND ssec.STATE IN (2,4,8)
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = ssec.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = ssec.SUBSCRIPTIONTYPE_ID
 WHERE
     rel.RTYPE = 1
 AND 
	prod.NAME like '%Buddy 50%%'
 AND 
	rel.STATUS = 1
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTIONS s
         WHERE
             s.OWNER_CENTER = rel.RELATIVECENTER
             AND s.OWNER_ID = rel.RELATIVEID
             AND s.STATE IN (2,4,8)
     )
 AND ssec.OWNER_CENTER in ($$scope$$)
 ORDER BY 
	Buddy_Club asc

