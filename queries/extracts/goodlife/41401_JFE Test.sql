SELECT
    name,
    text,
    creation_time as creation
FROM
    journalentries
WHERE
    person_center = 27

LIMIT 100