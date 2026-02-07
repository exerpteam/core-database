SELECT
        DISTINCT p.external_id
FROM
        leejam.persons p
WHERE
        (
        p.national_id = :ID
        OR
        p.resident_id = :ID 
        )
        AND
        p.external_id IS NOT NULL