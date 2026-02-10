-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
	p.center ||'p'|| p.id as personID, 
    p.external_id as externalID,
	p.fullname
	--email.txtvalue AS Email
FROM
	PERSONS p 
--LEFT JOIN PERSON_EXT_ATTRS email ON p.center = email.PERSONCENTER AND p.id = email.PERSONID AND email.name = '_eClub_Email'
where 
	p.external_id not in (
	select distinct 
		p2.external_id
	from 
		PERSON_EXT_ATTRS pea 
	join 
		persons p2	
	on p2.center = pea.PERSONCENTER
	AND p2.id = pea.PERSONID
where 
	pea.NAME = 'LoyaltyTCs'
and 
	p2.center in ($$scope1$$)
AND
	p2.external_id IS NOT NULL
)
AND
	p.center in ($$scope2$$)
and 
	p.STATUS IN (1,3)
