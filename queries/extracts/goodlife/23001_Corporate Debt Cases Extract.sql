-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	p.center || 'p' || p.id AS PersonID, 
	p.external_id AS ExternalID,
	CASE p.status 
	WHEN 0 THEN 'LEAD' 
	WHEN 1 THEN 'ACTIVE' 
	WHEN 2 THEN 'INACTIVE' 
	WHEN 3 THEN 'TEMPORARY INACTIVE' 
	WHEN 4 THEN 'TRANSFERRED' 
	WHEN 5 THEN 'DUPLICATE' 
    WHEN 6 THEN 'PROSPECT' 
	WHEN 7 THEN 'DELETED' 
	WHEN 8 THEN 'ANONIMIZED' 
	WHEN 9 THEN 'CONTACT' 
	ELSE 'UNKNOWN' END AS PersonStatus,
	p.fullname,
	ar.balance,
	ccc.startdate, 
	ccc.hold,
	ccc.currentstep,
	ccc.nextstep_date,
 	home.txtvalue AS HomePhone,
    mobile.txtvalue AS MobilePhone,
    workphone.txtvalue AS WorkPhone,
	cp.fullname AS CompanyName,
	companytype.txtvalue AS CompanyType

FROM 
	account_receivables ar
JOIN 
	persons p
ON 
	p.center = ar.customercenter 
	AND p.id = ar.customerid
	AND p.persontype = 4
JOIN 
	cashcollectioncases ccc
ON	
	ccc.personcenter = p.center 
	AND ccc.personid = p.id
	AND ccc.closed = 'f'
	AND ccc.currentstep >= 3
JOIN
  	RELATIVES r
ON 
	p.center = r.center
 	AND p.ID = r.ID
  	AND rtype = 3
  	AND r.status = 1
JOIN
	persons cp
ON
	r.relativecenter = cp.center 
	AND r.relativeid = cp.id
JOIN
  	PERSON_EXT_ATTRS CompanyType
ON
  	cp.CENTER = companytype.PERSONCENTER
  	AND cp.ID = companytype.PERSONID
  	AND companytype.NAME = 'COMPANYTYPE'
	AND companytype.txtvalue IN ('KAP','KAFP','CONTRA')
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
    AND p.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
WHERE
	ar.balance < 0