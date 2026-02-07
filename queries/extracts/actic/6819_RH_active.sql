SELECT DISTINCT 
	P.CENTER, 
	P.ID, 
	(select c.lastname from persons c where c.center = r.center and c.id = r.id ) as companyname,
    CASE  P.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END PERSONTYPE,   
	P.FIRSTNAME, 
	P.MIDDLENAME, 
	P.LASTNAME,   
	P.COUNTRY,   
	P.SEX,
	P.CITY  
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
on 
	pm.personcenter = p.center 
	and pm.personid = p.id 
	and pm.name = '_eClub_PhoneSMS' 
WHERE 
	P.CENTER IN (:Scop)
AND
	p.status = '1'
