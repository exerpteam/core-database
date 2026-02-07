SELECT
	p.center || 'p' || p.id AS PersonId,
    external_id
FROM PERSONS p
WHERE p.external_id IN (:listExternalId)