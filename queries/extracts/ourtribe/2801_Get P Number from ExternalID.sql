-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	p.center || 'p' || p.id AS PersonId,
    external_id
FROM PERSONS p
WHERE p.external_id IN (:listExternalId)