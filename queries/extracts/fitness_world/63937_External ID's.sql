-- The extract is extracted from Exerp on 2026-02-08
--  
select
center ||'p'|| id AS PERSON_ID,
external_id AS EXTERNAL_ID
from
persons
where
External_id in (:externalID)