SELECT 
	p.center || 'p' || p.id,
	pe.txtvalue

FROM persons p

JOIN person_ext_attrs pe

ON
	p.center = pe.personcenter
AND
	p.id = pe.personid
AND
	pe.name = '_eClub_OldSystemPersonId'

WHERE
	p.center || 'p' || p.id IN ($$PERSONID$$)