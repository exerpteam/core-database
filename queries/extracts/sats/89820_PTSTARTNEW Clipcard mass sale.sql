 WITH params as MATERIALIZED
(
        SELECT    
              dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)  AS fromDate,
              dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id) -1  AS toDate,
              c.id as centerId,
              c.country
        FROM centers c
)
        
SELECT        
        par.country,
        c.center,
        c.owner_center || 'p' || c.owner_id AS personid,
        prod.globalid,
        c.clips_initial,
        c.clips_left,
        c.finished,
        c.cancelled,
        emp.center || 'emp' || emp.id AS EmployeeId_creator,
        p.fullname AS EmployeeName_creator
FROM clipcards c
JOIN params par 
        ON c.center = par.centerId
JOIN products prod
        ON c.center = prod.center
        AND c.id = prod.id
JOIN sats.invoices inv
        ON c.invoiceline_center = inv.center
        AND c.invoiceline_id = inv.id
JOIN sats.employees emp
        ON emp.center = inv.employee_center 
        AND emp.id = inv.employee_id
JOIN sats.persons p
        ON p.center = emp.personcenter
        AND p.id = emp.personid
WHERE
        c.valid_from BETWEEN par.fromDate and par.toDate
        AND prod.globalid = 'PTSTARTNEW'
ORDER BY 1,2

