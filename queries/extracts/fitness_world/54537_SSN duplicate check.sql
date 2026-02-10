-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.CENTER || 'p' || p.ID AS PersonId,
		p.FULLNAME,
        p.SSN
FROM
        FW.PERSONS p
WHERE
        p.SSN IN (

        SELECT
                p.SSN
        FROM 
                FW.PERSONS p
        WHERE
                p.STATUS IN (1,3)
                AND p.SSN IS NOT NULL
                AND p.CURRENT_PERSON_CENTER = p.CENTER
                AND p.CURRENT_PERSON_ID = p.ID
                AND p.CENTER IN (:Scope)
        GROUP BY 
                p.SSN 
        HAVING COUNT(*) > 1
)
	AND p.CURRENT_PERSON_CENTER = p.CENTER
        AND p.CURRENT_PERSON_ID = p.ID
        AND p.CENTER IN (:Scope)
ORDER BY p.SSN