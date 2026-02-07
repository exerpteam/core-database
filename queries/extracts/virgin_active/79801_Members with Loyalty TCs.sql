SELECT distinct
    p.center ||'p'|| p.id as personID, 
	p.external_id as externalID,
    p.center as center,
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
JOIN PERSON_EXT_ATTRS pea
ON pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 
WHERE
pea.NAME = 'LoyaltyTCs'
AND
p.center in (:scope)
and 
pea.txtvalue is not null
