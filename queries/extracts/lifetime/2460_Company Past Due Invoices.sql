-- The extract is extracted from Exerp on 2026-02-08
-- Extract identifies all unpaid invoices for companies and shows correct aging on each invoice to indicate which company needs to be contacted.
SELECT DISTINCT
    p.fullname AS "Company Name"
    ,p.center || 'p' || p.id AS "Company Person ID"
    ,prs.ref AS "Invoice Number"
    ,pr.req_date AS "Invoice Date"
    ,pr.due_date AS "Invoice Due Date"
    ,prs.total_invoice_amount AS "Invoice Amount"
    ,prs.open_amount AS "Unsettled Amount"
    ,CURRENT_DATE - pr.due_date AS "Days Past Due"
    ,(CASE
        WHEN (CURRENT_DATE - pr.due_date) <= 0
        THEN 'Current'
        WHEN (CURRENT_DATE - pr.due_date) <= 30 AND (CURRENT_DATE - pr.due_date) > 0
        THEN '30 Days'
        WHEN (CURRENT_DATE - pr.due_date) <= 60 AND (CURRENT_DATE - pr.due_date) > 30
        THEN '60 Days'
        WHEN (CURRENT_DATE - pr.due_date) <= 90 AND (CURRENT_DATE - pr.due_date) > 60
        THEN '90 Days'
        WHEN (CURRENT_DATE - pr.due_date) <= 120 AND (CURRENT_DATE - pr.due_date) > 90
        THEN '120 Days'
        WHEN (CURRENT_DATE - pr.due_date) > 120
        THEN '> 120 Days'
     END
    ) AS "Aging"
    
FROM
        payment_requests pr
JOIN
        payment_request_specifications prs        
ON
        prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid
        AND prs.open_amount != 0  
JOIN
        ACCOUNT_RECEIVABLES ar        
ON       
        prs.ID = ar.ID
        AND prs.CENTER = ar.CENTER
        AND ar.ar_type = 4
JOIN        
        PERSONS p
ON
        p.ID = ar.CUSTOMERID
        AND p.CENTER = ar.CUSTOMERCENTER
WHERE
        pr.clearinghouse_id = 2
        AND pr.due_date <= (:CUT_DATE)
        AND p.sex = 'C'