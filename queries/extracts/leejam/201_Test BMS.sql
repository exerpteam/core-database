-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        e.personcenter,
        e.personid, 
        COUNT(*)
FROM employees e
JOIN centers c ON e.personcenter = c.id
WHERE

        e.blocked = false
GROUP BY
        e.personcenter,
        e.personid
HAVING COUNT(*) > 1