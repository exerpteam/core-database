-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        p.center||'p'||p.id AS "Company id"
        ,p.fullname AS "Company name"
        ,prs.ref AS "Invoice number"
        ,pr.req_date AS "Invoice date"
        ,ROUND((prs.total_invoice_amount - (prs.total_invoice_amount * 0.1304)),2) AS "Invoice amount ex VAT"
        ,ROUND((prs.total_invoice_amount * 0.1304),2) AS "VAT"
        ,prs.total_invoice_amount AS "Total invoice amount"
        ,prs.open_amount AS "Total amount due"
        ,pr.due_date AS "Due date"
        ,art.amount AS "Payment received"
        ,TO_CHAR(longtodateC(art.trans_time,art.center),'YYYY-MM-dd') AS "Payment date"
        ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid "Receipt number"
        ,ar.balance AS "Remaining balance"
        ,CASE 
                WHEN pr.state = 1 THEN 'New' 
                WHEN pr.state = 2 THEN 'Sent' 
                WHEN pr.state = 3 THEN 'Done' 
                WHEN pr.state = 4 THEN 'Done, manual' 
                WHEN pr.state = 5 THEN 'Rejected, clearinghouse' 
                WHEN pr.state = 6 THEN 'Rejected, bank' 
                WHEN pr.state = 7 THEN 'Rejected, debtor' 
                WHEN pr.state = 8 THEN 'Cancelled' 
                WHEN pr.state = 10 THEN 'Reversed, new' 
                WHEN pr.state = 11 THEN 'Reversed , sent' 
                WHEN pr.state = 12 THEN 'Failed, not creditor' 
                WHEN pr.state = 13 THEN 'Reversed, rejected' 
                WHEN pr.state = 14 THEN 'Reversed, confirmed' 
                WHEN pr.state = 17 THEN 'Failed, payment revoked' 
                WHEN pr.state = 18 THEN 'Done Partial' 
                WHEN pr.state = 19 THEN 'Failed, Unsupported' 
                WHEN pr.state = 20 THEN 'Require approval' 
                WHEN pr.state = 21 THEN 'Fail, debt case exists' 
                WHEN pr.state = 22 THEN 'Failed, timed out' 
                ELSE 'Undefined' 
        END AS "Payment Request State"
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
        payment_requests pr 
                ON pr.center = pag.center 
                AND pr.id = pag.id 
                AND pr.agr_subid = pag.subid
JOIN
        payment_request_specifications prs
                ON pr.inv_coll_center = prs.center
                AND pr.inv_coll_id = prs.id
                AND pr.inv_coll_subid = prs.subid         
LEFT JOIN      
        ar_trans art
                ON prs.center = art.payreq_spec_center 
                AND prs.id = art.payreq_spec_id
                AND prs.subid = art.payreq_spec_subid
                AND prs.ref = art.info              
WHERE
        p.center||'p'|| p.id = :Company
        AND
        pr.req_date BETWEEN :FromDate AND :ToDate                       

