/**
* Creator: Mikael Ahlberg
* Purpose: List members without checkins in given period.
*
*/
SELECT 
	DISTINCT p.CENTER || 'p' || p.ID AS PersonID, 
	c.NAME AS CenterName, 
	s.START_DATE AS StartDate, 
	s.BINDING_END_DATE AS BindingEndDate, 
	p.FULLNAME AS MemberName, 
	CASE  p.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active'  WHEN 2 THEN 'Inactive'  WHEN 3 THEN 'Temporary inactive'  WHEN 4 THEN 'Transferred'  WHEN 5 THEN 'Duplicate'  WHEN 6 THEN 'Prospect'  WHEN 7 THEN 'Deleted'  WHEN 8 THEN  'Anonimized'  WHEN 9 THEN  'Contact'  ELSE 'Unknown' END AS Status, 
	CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'One man corporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest' ELSE 'Unknown' END AS Persontype, 
	prod.NAME as ProductName, 
	pem.TXTVALUE as Email, 
	pm.TXTVALUE AS PhoneMobile 
FROM PERSONS p 
LEFT JOIN SUBSCRIPTIONS s ON
	p.CENTER = s.OWNER_CENTER  AND 
	p.ID = s.OWNER_ID 
LEFT JOIN CENTERS c ON 
	p.CENTER = c.ID
LEFT JOIN ENTITYIDENTIFIERS e1 ON
	p.CENTER = e1.REF_CENTER AND 
	p.ID = e1.REF_ID AND 
	e1.IDMETHOD = 1 AND 
	e1.ENTITYSTATUS = 1 
LEFT JOIN ENTITYIDENTIFIERS e2 ON
	p.CENTER = e2.REF_CENTER AND 
	p.ID = e2.REF_ID AND 
	e2.IDMETHOD = 2 AND 
	e2.ENTITYSTATUS = 1 
LEFT JOIN ENTITYIDENTIFIERS e4 ON 
	p.CENTER = e4.REF_CENTER AND 
	p.id = e4.REF_ID AND 
	e4.IDMETHOD = 4 AND 
	e4.ENTITYSTATUS = 1 
LEFT JOIN ENTITYIDENTIFIERS e5 ON
	p.CENTER = e5.REF_CENTER AND
	p.ID = e5.REF_ID AND 
	e5.IDMETHOD = 5 AND 
	e5.ENTITYSTATUS = 1 
LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN RELATIVES r ON 
	p.CENTER = r.RELATIVECENTER AND 
	p.ID = r.RELATIVEID AND 
	r.RTYPE = 2 AND 
	r.STATUS <> 3 
LEFT JOIN PERSON_EXT_ATTRS ph ON 
	ph.PERSONCENTER = p.CENTER AND 
	ph.PERSONID = p.ID AND 
	ph.NAME = '_eClub_PhoneHome' 
LEFT JOIN PERSON_EXT_ATTRS pem ON 
	pem.PERSONCENTER = p.CENTER AND 
	pem.PERSONID = p.ID AND 
	pem.NAME = '_eClub_Email' 
LEFT JOIN PERSON_EXT_ATTRS pm ON 
	pm.PERSONCENTER = p.CENTER AND 
	pm.PERSONID = p.ID AND 
	pm.NAME = '_eClub_PhoneSMS' 
WHERE p.CENTER IN ($$scope$$) AND 

-- Exclude all members that have checkedin
NOT EXISTS(
	SELECT * FROM CHECKINs log
	WHERE 
		log.person_CENTER = p.CENTER AND 
		log.person_ID = p.ID AND 
		log.CHECKIN_TIME >= :No_Check_in_from_date AND 
		log.CHECKIN_TIME <= :No_Check_in_To_date + 1
	) 
AND p.STATUS = 1 -- Only active
AND p.PERSONTYPE != 2 -- Exclude staff
AND s.STATE = 2 -- Only active
AND prod.PRIMARY_PRODUCT_GROUP_ID IN (7, 8, 9, 10, 11, 12, 218, 219, 221, 222)

-- Product groups
-- 7-9 = EFT Subscriptions, 10-12 = CASH subscriptions, 218+222 = EFT campaign subscriptions, 219+221 = CASH campaign subscriptions
-- 18 = add-on subscriptions, 624 = Lifestyle, 826 = Excluded


