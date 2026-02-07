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
	pea.txtvalue AS Loyalty_TCs,
	lai.txtvalue AS Loyalty_account_id,
	lci.txtvalue AS Loyalty_customer_id,
	lii.txtvalue AS Loyalty_identifier_ID,
	p.birthdate
FROM
	PERSONS p
JOIN PERSON_EXT_ATTRS pea
ON pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 
LEFT JOIN
     PERSON_EXT_ATTRS lai
 ON lai.PERSONCENTER = p.CENTER
 AND lai.PERSONID = p.ID
 AND lai.NAME='LAID'
LEFT JOIN
     PERSON_EXT_ATTRS lci
 ON  lci.PERSONCENTER = p.CENTER
 AND lci.PERSONID = p.ID
 AND lci.NAME='LCID'
LEFT JOIN
     PERSON_EXT_ATTRS lii
 ON  lii.PERSONCENTER = p.CENTER
 AND lii.PERSONID = p.ID
 AND lii.NAME='LOYALTY'
WHERE
pea.NAME = 'LoyaltyTCs'
AND
p.center in (:scope)
and 
pea.txtvalue is not null
