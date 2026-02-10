-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.CENTER || 'p' || p.ID as MemberID,
p.FULLNAME,
p.SSN
FROM
    persons p
WHERE
    p.SSN IN
    (
        SELECT
            --COUNT(PERSONS.SSN),
            PERSONS.SSN
        FROM
            FW.PERSONS
        WHERE
            PERSONS.STATUS IN (0,2,6,9)
            AND PERSONS.FIRSTNAME IS NOT NULL
			
        GROUP BY
            PERSONS.FIRSTNAME,
            PERSONS.SSN
        HAVING
            (
                COUNT(PERSONS.SSN) > 1 ) )
AND p.CENTER IN (:scope)
AND p.STATUS in (1,3)
