-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct
        p.center||'p'||p.id as personID 
        ,p.fullname
        ,CASE
                WHEN p.status = 0 THEN 'LEAD'
                WHEN p.status = 1 THEN 'ACTIVE'
                WHEN p.status = 2 THEN 'INACTIVE'
                WHEN p.status = 3 THEN 'TEMPORARYINACTIVE'
                WHEN p.status = 4 THEN 'TRANSFERED'
                WHEN p.status = 5 THEN 'DUPLICATE'
                WHEN p.status = 6 THEN 'PROSPECT'
                WHEN p.status = 7 THEN 'DELETED'
                WHEN p.status = 8 THEN 'ANONYMIZED'
                WHEN p.status = 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
        END AS PersonStatus
        ,r.rolename
        ,p.external_id AS "External ID"
        ,emp.center || 'emp' ||emp.ID as "EmployeeID"
from persons p
join employees emp 
                on p.center = emp.personcenter 
                and p.id = emp.personid
join employeesroles er
                on emp.center = er.center 
                and emp.id = er.id
join roles r
                on r.id = er.roleid                                
where emp.blocked = 'false'