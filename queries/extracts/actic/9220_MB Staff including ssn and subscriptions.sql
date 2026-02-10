-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT 
	P.CENTER, 
	P.ID, 
    p.center || 'p' || p.id personid,
	(select c.lastname from persons c where c.center = r.center and c.id = r.id ) as companyname, 
	P.BLACKLISTED, 
    DECODE (P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
	P.FIRSTNAME, 
	P.MIDDLENAME, 
	P.LASTNAME, 
	P.ADDRESS1, 
	P.ADDRESS2, 
	P.COUNTRY, 
	P.ZIPCODE, 
	P.BIRTHDATE, 
    P.SSN,
	P.SEX, 
	P.PINCODE, 
	P.FRIENDS_ALLOWANCE, 
	P.CITY, 
	ph.txtvalue AS phonehome, 
	pm.txtvalue AS phonemobile, 
	pem.txtvalue AS email,
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date
FROM 
	PERSONS P 
LEFT JOIN SUBSCRIPTIONS S 
ON  
	P.CENTER = S.OWNER_CENTER  
	AND P.ID = S.OWNER_ID 
left join relatives r 
on 
	p.center = r.relativecenter 
	and p.id = r.relativeid 
	and r.rtype = 2 
	and r.status <> 3 
left join person_ext_attrs ph 
on 
	ph.personcenter = p.center 
	and ph.personid = p.id 
	and ph.name = '_eClub_PhoneHome' 
left join person_ext_attrs pem 
on 
	pem.personcenter = p.center 
	and pem.personid = p.id 
	and pem.name = '_eClub_Email' 
left join person_ext_attrs pm 
	on pm.personcenter = p.center 
	and pm.personid = p.id 
	and pm.name = '_eClub_PhoneSMS' 
WHERE 
	P.CENTER IN (:Scope)
	AND P.PERSONTYPE IN ( :persontype )
	AND P.STATUS IN ( :PersonStatus )
	AND (S.SUBSCRIPTIONTYPE_CENTER, S.SUBSCRIPTIONTYPE_ID) in(SELECT center,id FROM PRODUCTS WHERE PTYPE = 10 AND GLOBALID IN ( :globalsubtype ) AND center IN (S.CENTER))
	AND S.STATE IN ( :Subscription_state )
