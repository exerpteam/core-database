-- The extract is extracted from Exerp on 2026-02-08
--  
select pr.*

from 
        payment_agreements pag 
JOIN 
        account_receivables ar ON ar.center = pag.center AND ar.id = pag.id
JOIN 
        persons p ON p.center = ar.customercenter AND p.id = ar.customerid 
JOIN 
        payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
where 
        ar.customercenter = 105
        and ar.customerid = 403