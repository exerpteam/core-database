SELECT 
	pe.txtvalue AS OldSystemID,
	p.center || 'p' || p.id AS PersonID

FROM person_ext_attrs pe 

JOIN persons p

ON
	p.center = pe.personcenter
AND
	p.id = pe.personid
AND
	pe.name = '_eClub_OldSystemPersonId'

WHERE
	pe.txtvalue IN ($$OLDSYSTEMID$$)