select
persons.center||'p'||persons.id as PersonId,
persons.external_id as ExternalId
from stjames.persons where persons.external_id like 'CA%';