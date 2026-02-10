-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        DISTINCT
        (CASE
                WHEN art.status = 'OPEN' AND art.payreq_spec_center IS NOT NULL THEN 'Partially Paid but still open, Already in Payment Request'
                WHEN art.status = 'OPEN' AND art.payreq_spec_center IS NULL THEN 'Partially Paid but still open, No payment Request'
                WHEN art.status = 'NEW' AND art.payreq_spec_center IS NOT NULL THEN 'Not settled yet, already linked to Payment Request'
                WHEN art.status = 'NEW' AND art.payreq_spec_center IS NULL THEN 'Not settled yet, No payment Request'
                WHEN art.center IS NULL AND i.fiscal_reference = 'REVOKED' THEN 'IMPORTANT: Scenario NOT supported'
                WHEN art.center IS NULL AND i.fiscal_reference IS NULL AND trunc(longtodatec(i.entry_time, i.center)) = current_date THEN 'Ready to Sync TONIGHT'
                WHEN art.center IS NULL AND i.fiscal_reference IS NULL THEN 'SHOULD BE SYNC, STAND ALONE TRANSACTIONS,  PLEASE INVESTIGATE'
                WHEN art.status = 'CLOSED' THEN 'SHOULD BE SYNC, PAYMENT ACCOUNT TRANSACTIONS, PLEASE INVESTIGATE'
                ELSE 'WIP'
        END) AS Reason,
        p.status,
        longtodatec(i.entry_time, i.center) as entrytime, 
        i.center || 'inv' || i.id AS InvoiceNumber,
        i.center,
        i.id,
        i.payer_center || 'p' || i.payer_id AS PayerId,
        i.text,
        SUM(il.total_amount) over (partition BY il.CENTER,il.ID) AS TotalAmount,
        i.fiscal_export_token,
        i.fiscal_reference,
        art.text,
        art.status,
        art.unsettled_amount,
        art.collected,
        art.payreq_spec_center,
        art.payreq_spec_id,
        art.payreq_spec_subid
FROM vivagym.invoices i
JOIN vivagym.centers c ON c.id = i.center AND c.country = 'PT'
JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN vivagym.persons p ON i.payer_center = p.center AND i.payer_id = p.id
LEFT JOIN vivagym.ar_trans art ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
WHERE
        (i.fiscal_reference IS NULL OR i.fiscal_reference = 'REVOKED')
        AND p.sex != 'C'
        AND i.text NOT IN ('Converted subscription invoice')
        AND il.net_amount != 0