-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    person_center ||'p'||person_id   AS personId,
    p.external_id                    AS externalId,
    convert_from(j.big_text, 'UTF8') AS journalNotes
FROM
    journalentries j
INNER JOIN 
    persons p 
ON 
    p.center = j.person_center 
AND p.id = j.person_id
WHERE
    convert_from(j.big_text, 'UTF8') LIKE '%DEBT'||TO_CHAR(CURRENT_DATE, 'MM')||'%';