SELECT
p.center ||'p'|| p.id AS memberid,
p.external_id,
p.ssn
FROM
persons p
WHERE
(p.center,p.id) IN (:members)