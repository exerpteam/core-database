-- The extract is extracted from Exerp on 2026-02-08
-- 	
WITH
    duplicates AS
    (
        SELECT
            ssn,
            COUNT(*) AS num_of_duplicates
        FROM
            persons p
        GROUP BY
            ssn
        HAVING
            COUNT(*) > 1
    )
SELECT
    p.center||'p'||p.id AS MemberID,
    CASE
        WHEN p.status = 0
        THEN 'Lead'
        WHEN p.status = 1
        THEN 'Active'
        WHEN p.status = 2
        THEN 'Inactive'
        WHEN p.status = 3
        THEN 'TemporaryInactive'
        WHEN p.status = 4
        THEN 'Transferred'
        WHEN p.status = 5
        THEN 'Duplicate'
        WHEN p.status = 6
        THEN 'Prospect'
        WHEN p.status = 7
        THEN 'Deleted'
        WHEN p.status = 8
        THEN 'Anonymized'
        WHEN p.status = 9
        THEN 'Contact'
        ELSE 'Undefined'
    END               AS PersonStatus,
    p.ssn             AS CPR_number,
    num_of_duplicates AS "Number of duplicates"
FROM
    PERSONS p
JOIN
    duplicates dup
ON
    dup.ssn = p.ssn
ORDER BY
    p.ssn