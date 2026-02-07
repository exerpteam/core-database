SELECT
        art.status,
        il.person_center || 'p' || il.person_id,
        il.*
FROM vivagym.payment_requests pr
JOIN vivagym.invoice_lines_mt il ON pr.reject_fee_invline_center = il.center AND pr.reject_fee_invline_id = il.id AND pr.reject_fee_invline_subid = il.subid
JOIN vivagym.ar_trans art ON art.ref_center = il.center AND art.ref_id = il.id AND art.ref_type = 'INVOICE'
WHERE
        pr.req_date BETWEEN TO_DATE('2023-01-17','YYYY-MM-DD') AND TO_DATE('2023-01-18','YYYY-MM-DD')
        AND pr.reject_fee_invline_center IS NOT NULL
        AND art.status IN ('NEW')