SELECT DISTINCT 
       p.center||'p'||p.id AS "Company id"
       ,p.fullname AS "Company name"
       ,emppam.fullname AS "Account manager"
       ,ppart.fullname AS "Parent company"
       ,prs.ref AS "Invoice number"
       ,longtodateC(prs.entry_time,prs.center) AS "Invoice date"
       ,ROUND((prs.total_invoice_amount - (prs.total_invoice_amount * 0.1304)),2) AS "Invoice amount ex VAT"
       ,ROUND((prs.total_invoice_amount * 0.1304),2) AS "VAT"
       ,prs.total_invoice_amount AS "Total invoice amount"
       ,ar.balance AS "Total amount due"
       ,pr.due_date AS "Due date"
       ,ROUND((prs.open_amount - (prs.open_amount * 0.1304)),2) AS "Amount overdue"
       ,ROUND((prs.open_amount * 0.1304),2) AS "VAT overdue"
       ,prs.open_amount  AS "Total amount overdue"
       ,CASE
                WHEN prs.open_amount  != 0 THEN current_date - pr.due_date 
                ELSE 0
        END AS "Days overdue"
FROM 
        payment_requests pr
JOIN
        payment_request_specifications prs
                ON pr.inv_coll_center = prs.center
                AND pr.inv_coll_id = prs.id
                AND pr.inv_coll_subid = prs.subid         
JOIN
        payment_agreements pag 
                ON pr.center = pag.center 
                AND pr.id = pag.id 
                AND pr.agr_subid = pag.subid
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
        employees empam
                ON empam.center = AccountMGR.relativecenter
                AND empam.id = AccountMGR.relativeid
JOIN
        persons emppam
                ON emppam.center = empam.personcenter
                AND emppam.id = empam.personid
LEFT JOIN
        relatives part
                ON part.relativecenter = p.center
                AND part.relativeid = p.id
                AND part.rtype = 6 
                AND part.status = 1 
                AND (part.expiredate IS NULL OR part.expiredate > Current_Date)
LEFT JOIN
        persons ppart
                ON ppart.center = part.center
                AND ppart.id = part.id
                and ppart.persontype = 4 
JOIN      
        ar_trans art
                ON prs.center = art.payreq_spec_center 
                AND prs.id = art.payreq_spec_id
                AND prs.subid = art.payreq_spec_subid
JOIN
        invoices inv
                ON art.ref_center = inv.center
                AND art.ref_id = inv.id 
JOIN
        invoice_lines_mt invl
                ON invl.center = inv.center
                AND invl.id = inv.id 
--LEFT JOIN      
--        art_match armatch
--                ON armatch.art_paid_center = art.center
--                AND armatch.art_paid_id = art.id
--                AND armatch.art_paid_subid = art.subid                              
--LEFT JOIN
--        ar_trans payment
--                ON payment.center = armatch.art_paying_center
--                AND payment.id = armatch.art_paying_id                
--                AND payment.subid = armatch.art_paying_subid           
WHERE
        p.center in (:Scope)  
        AND
        prs.open_amount != 0
        AND              
        pr.due_date < current_date