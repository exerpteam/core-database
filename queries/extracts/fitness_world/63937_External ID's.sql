-- This is the version from 2026-02-05
--  
select
center ||'p'|| id AS PERSON_ID,
external_id AS EXTERNAL_ID
from
persons
where
External_id in (:externalID)