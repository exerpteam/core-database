-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.*,
        t2.counter AS "Number of employee Ids"
FROM 

        (SELECT
               p.external_id,
               p.center || 'p' || p.id AS "PersonId",
               emp.center || 'emp' || emp.id AS "EmployeeId"
        FROM goodlife.persons p
        JOIN goodlife.employees emp ON p.center = emp.personcenter AND p.id = emp.personid
        WHERE p.persontype IN (2)
        AND emp.blocked = 'false') t1
JOIN 
        (SELECT
               p.external_id,
               count(*) AS "counter"
        FROM goodlife.persons p
        JOIN goodlife.employees emp ON p.center = emp.personcenter AND p.id = emp.personid
        WHERE p.persontype IN (2)
        AND emp.blocked = 'false'
        group by p.external_id) t2
ON t1.external_id=t2.external_id        
