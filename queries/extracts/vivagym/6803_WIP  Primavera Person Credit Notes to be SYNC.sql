-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        DISTINCT 
        (CASE
                WHEN art.center IS NULL THEN 'SHOULD BE SYNC, STAND ALONE TRANSACTIONS,  PLEASE INVESTIGATE'
                WHEN art.center IS NOT NULL AND i.center IS NOT NULL AND i.fiscal_reference IS NULL THEN 'WAITING FOR INVOICE TO SYNC WITH PRIMAVERA'
                WHEN art.center IS NOT NULL AND art.status = 'CLOSED' AND i.fiscal_reference IS NOT NULL THEN 'Ready to be SYNC TONIGHT'
                WHEN art.center IS NOT NULL AND art.status IN ('OPEN','NEW') AND i.fiscal_reference IS NOT NULL THEN 'CREDITNOTE IS NOT SETTLED, BUT LINKED TO A SYNC INVOICE, SHOULD IT BE SENT TO PRIMAVERA'
                ELSE 'WIP'
        END) AS Reason,
        cn.center || 'cred' || cn.id AS CreditNoteNumber,
        cn.payer_center || 'p' || cn.payer_id AS PayerId,
        cn.text,
        SUM(cnl.total_amount) over (partition BY cnl.CENTER,cnl.ID) AS TotalAmount,
        cn.fiscal_export_token,
        cn.fiscal_reference,
        i.center,
        i.id,
        i.fiscal_reference,
        art.text,
        art.status,
        art.unsettled_amount,
        art.collected,
        art.payreq_spec_center,
        art.payreq_spec_id,
        art.payreq_spec_subid
FROM vivagym.credit_notes cn
JOIN vivagym.centers c ON c.id = cn.center AND c.country = 'PT'
JOIN vivagym.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
JOIN vivagym.persons p ON cn.payer_center = p.center AND cn.payer_id = p.id
LEFT JOIN vivagym.ar_trans art ON art.ref_center = cn.center AND art.ref_id = cn.id AND art.ref_type = 'CREDIT_NOTE'
LEFT JOIN invoice_lines_mt il
                        ON cnl.invoiceline_center = il.center
                        AND cnl.invoiceline_id = il.id
                        AND cnl.invoiceline_subid = il.subid
LEFT JOIN vivagym.invoices i
                        ON il.center = i.center
                        AND il.id = i.id
WHERE
        (cn.fiscal_reference IS NULL OR cn.fiscal_reference = 'REVOKED')
        AND p.sex != 'C'
        AND cnl.net_amount != 0