-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    description AS
    (
        SELECT
            je2.creation_time,
            je2.person_center,
            je2.person_id,
            CAST(convert_from(je2.big_text, 'UTF-8') AS TEXT) AS reason
        FROM
            journalentries je2
        WHERE
            je2.name IN ('Svartelistet',
                         'Blacklist State Unchanged',
                         'Svartlistad',
                         'Blacklisted',
                         'Blacklisted min. 2 år')
    )
SELECT
    p2.center||'p'||p2.id AS "_eClub_PERSON_ID",
    --t.blacklisted,
    p2.external_id AS "External ID",
    longtodateC(t.creation_time, p2.center) AS "Blacklist date",
    de.reason AS "Reason"
FROM
    (
        SELECT
            p.center,
            p.id,
            p.current_person_center,
            p.current_person_id,
            p.blacklisted,
            p.external_id,
            MAX(je.creation_time) AS creation_time
        FROM
            persons p
        JOIN
            journalentries je
        ON
            je.person_center = p.center
        AND je.person_id = p.id
        AND je.name IN ('Svartelistet',
                        'Blacklist State Unchanged',
                        'Svartlistad',
                        'Blacklisted',
                        'Blacklisted min. 2 år')
        WHERE
            p.blacklisted = 1
        GROUP BY
            p.center,
            p.id,
            p.current_person_center,
            p.current_person_id,
            p.blacklisted,
            p.external_id ) t
JOIN
    description de
ON
    de.person_center = t.center
AND de.person_id = t.id
AND de.creation_time = t.creation_time
JOIN
    persons p2
ON
    p2.center = t.current_person_center
AND p2.id = t.current_person_id
WHERE
p2.CENTER in (:Scope)
ORDER BY
    p2.center,
    p2.id