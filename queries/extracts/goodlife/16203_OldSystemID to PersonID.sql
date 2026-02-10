-- The extract is extracted from Exerp on 2026-02-08
-- Extract created to give the eXerp Person ID using the Legacy membership # from Filepro

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