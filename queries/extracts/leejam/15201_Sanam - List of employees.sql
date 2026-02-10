-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        emp.center||'emp'||emp.id as EmployeeID
        ,emp.personcenter||'p'||emp.personid as PersonID
        ,emp.center as ClubID
        ,c.name as ClubName 
FROM 
        employees emp
JOIN 
        centers c
        ON c.id = emp.center
WHERE
        emp.blocked IS FALSE
                