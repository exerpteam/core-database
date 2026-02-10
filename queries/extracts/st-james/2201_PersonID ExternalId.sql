-- The extract is extracted from Exerp on 2026-02-08
-- Used by STJ team post migration to get mapping of person ID to External ID
select
persons.center||'p'||persons.id as PersonId,
persons.external_id as ExternalId
from stjames.persons where persons.external_id like 'CA%';