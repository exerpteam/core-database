-- The extract is extracted from Exerp on 2026-02-08
-- This extract finds duplicates and transfers based on input of external_id
WITH RECURSIVE duplicateMembers (center, id, current_person_center, current_person_id, external_id) AS(
	SELECT center, id, current_person_center, current_person_id, external_id
		FROM persons p
		WHERE p.external_id = :ExternalId 
	UNION
	SELECT p.center, p.id, p.current_person_center, p.current_person_id, p.external_id
		FROM persons p, duplicateMembers dM
		WHERE p.id = dM.current_person_id AND p.center = dM.current_person_center
		OR dM.id = p.current_person_id AND dM.center = p.current_person_center
)
SELECT 
center, 
id, 
CASE WHEN center = current_person_center AND id = current_person_id THEN 1 ELSE 0 END as is_current,
external_id
FROM duplicateMembers