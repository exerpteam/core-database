-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.center ||'p'|| p.id AS memberid,
p.external_id,
s.start_date
FROM
persons p

join subscriptions s
on
p.center = s.owner_center
and
p.id = s.owner_id

WHERE
p.center in (:scope)
and p.ssn is null
and p.status in (1,3)
and s.state in (2,4)
and s.start_date > '2025-01-01' 