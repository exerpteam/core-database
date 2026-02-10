-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
       emppam.center||'p'||emppam.id AS "Account manager id"
       ,emppam.fullname AS "Account manager"
       ,p.center||'p'||p.id AS "Company id"
       ,p.fullname AS "Company name"
       ,prs.ref AS "Invoice id"
       ,pr.req_date AS "Invoice date"
       ,pr.due_date AS "Invoice due date"
       ,prs.total_invoice_amount AS "Amount"
FROM 
        payment_agreements pag 
JOIN 
        account_receivables ar 
                ON ar.center = pag.center 
                AND ar.id = pag.id
JOIN 
        persons p 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid
                AND p.sex = 'C' 
JOIN
        relatives AccountMGR
                ON AccountMGR.center = p.center
                AND AccountMGR.id = p.id
                AND AccountMGR.rtype = 10
                AND AccountMGR.status = 1
                AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)

JOIN
       persons emppam
                ON emppam.center = AccountMGR.relativecenter
                AND emppam.id = AccountMGR.relativeid             
JOIN 
        payment_requests pr 
                ON pr.center = pag.center 
                AND pr.id = pag.id 
                AND pr.agr_subid = pag.subid
JOIN
        payment_request_specifications prs
                ON pr.inv_coll_center = prs.center
                AND pr.inv_coll_id = prs.id
                AND pr.inv_coll_subid = prs.subid               
WHERE 
        pr.due_date < Current_Date + 6
        AND
        prs.total_invoice_amount != 0