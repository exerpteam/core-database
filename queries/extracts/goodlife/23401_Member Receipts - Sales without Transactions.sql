-- The extract is extracted from Exerp on 2026-02-08
--  
-- PARAMS
-- ------------
-- ClubId : integer
-- PersonId : integer
-- StartDate : date
-- EndDate : date

SELECT 

    (((il.center || 'inv') || il.id) || 'ln') || il.subid AS "SalesLineId", TO_CHAR(longtodatec(i.trans_time, i.center), 'YYYY-MM-DD HH24:MI:SS') AS "TransactionDateTime",
    prod.name AS "ProductName",
    il.net_amount AS "NetAmount",
    il.total_amount - il.net_amount AS "TaxAmount",
    il.total_amount AS "TotalAmount"

FROM invoice_lines_mt il

JOIN invoices i  
    ON il.center = i.center  
    AND il.id = i.id 
    AND CAST(TO_CHAR(longtodateC(i.trans_time, il.center), 'YYYY-MM-DD') AS DATE) BETWEEN :StartDate AND :EndDate

LEFT JOIN credit_note_lines_mt cred_line -- link to the credit notes table to remove Partial Credit Note transactions
    ON il.center = cred_line.invoiceline_center
    AND il.id = cred_line.invoiceline_id
    AND il.subid = cred_line.invoiceline_subid

JOIN persons p  
    ON p.center = il.person_center  
    AND p.id = il.person_id
    AND p.center = :ClubId AND p.id = :PersonId

LEFT JOIN ar_trans trans  
    ON trans.ref_center = i.center
    AND trans.ref_id = i.id
    AND trans.ref_type ='INVOICE'

JOIN products prod  
    ON prod.center = il.productcenter  
    AND prod.id = il.productid

WHERE trans.id IS NULL 
    AND il.total_amount <> 0
    AND cred_line.invoiceline_id IS NULL -- only include transactions that do not have a Partial Credit Note