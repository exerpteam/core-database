-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        ar.customercenter || 'p' || ar.customerid AS payer_id,
        il.person_center || 'p' || il.person_id,
        longtodatec(art.entry_time,art.center) AS entry_Date, 
        art.text,
        -art.unsettled_amount,
		art.amount AS total_amount,
        i.center || 'inv' || i.id AS invoice_number
FROM stjames.invoices i
JOIN stjames.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN stjames.products pr ON il.productcenter = pr.center AND il.productid = pr.id
JOIN stjames.ar_trans art ON i.center = art.ref_center AND i.id = art.ref_id AND art.ref_type = 'INVOICE'
JOIN stjames.account_receivables ar ON ar.center = art.center AND ar.id = art.id
JOIN stjames.persons p ON p.center = ar.customercenter AND p.id = ar.customerid
WHERE
        pr.globalid = 'INFRASTRUCTURE_FEE'
        AND art.status NOT IN ('CLOSED')
        AND art.unsettled_amount != 0
        AND p.SEX NOT IN ('C')