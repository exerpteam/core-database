-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    p.center ||'p'|| p.id as personID, 
	p.external_id as externalID,
	p.fullname,
	p.birthdate,
	email.txtvalue AS Email,
	  CASE  p.STATUS  
		WHEN 0 THEN 'LEAD'  
		WHEN 1 THEN 'ACTIVE'  
		WHEN 2 THEN 'INACTIVE'  
		WHEN 3 THEN 'TEMPORARYINACTIVE'  
		WHEN 4 THEN 'TRANSFERED'  
		WHEN 5 THEN 'DUPLICATE'  
		WHEN 6 THEN 'PROSPECT'  
		WHEN 7 THEN 'DELETED' 
		WHEN 8 THEN  'ANONYMIZED'  
		WHEN 9 THEN  'CONTACT'  
		ELSE 'UNKNOWN' END AS person_status,
	  CASE  p.persontype  
		WHEN 0 THEN 'Private'  
		WHEN 1 THEN 'Student'  
		WHEN 2 THEN 'Staff'  
		WHEN 3 THEN 'Friend'  
		WHEN 4 THEN 'Corporate'  
		WHEN 5 THEN 'Onemancorporate'  
		WHEN 6 THEN 'Family'  
		WHEN 7 THEN 'Senior'  
		WHEN 8 THEN 'Guest'  
		WHEN 9 THEN  'Child'  
	WHEN 10 THEN  'External_Staff' 
	ELSE 'Unknown' END AS person_type,
	pea.txtvalue AS Loyalty_TCs
FROM
	PERSONS p
LEFT JOIN 
	PERSON_EXT_ATTRS pea
ON 
	pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 
LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
WHERE
pea.NAME = 'LoyaltyTCs'
AND
p.center in (:scope)
--and pea.txtvalue is not null