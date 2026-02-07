SELECT 
        longtodatec(el.time_stamp, el.reference_center) rejection_time,
        longtodatec(art.entry_time, art.center) as transationtime,
        el.time_stamp,
        art.entry_time,
        ar.customercenter  || 'p' || ar.customerid,
        pr.request_type,
        pr.clearinghouse_id,
        pr.req_amount,
        pay.req_date,
        pay.req_amount,
        art.status,
        art.amount,
        art.text,
        il.total_amount,
        il.text,
        rank() over (partition by ar.customercenter,ar.customerid ORDER BY art.entry_time DESC) ranking
FROM vivagym.event_log el
JOIN vivagym.payment_requests pr ON el.reference_center = pr.center AND el.reference_id = pr.id ANd el.reference_sub_id = pr.subid
JOIN vivagym.payment_request_specifications prs ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid
JOIN vivagym.payment_requests pay ON pay.inv_coll_center = prs.center AND pay.inv_coll_id = prs.id AND pay.inv_coll_subid = prs.subid AND pay.request_type = 1
JOIN vivagym.account_receivables ar ON ar.center = pr.center AND ar.id = pr.id AND ar.ar_type = 4
JOIN vivagym.ar_trans art ON ar.center = art.center AND ar.id = art.id
JOIN vivagym.invoices i ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
JOIN vivagym.products prod ON il.productcenter = prod.center AND il.productid = prod.id
WHERE
        el.event_configuration_id = 2401
        AND el.time_stamp > DATETOLONGC(TO_CHAR(TO_DATE('2023-01-18','YYYY-MM-DD'),'YYYY-MM-DD HH24:MI'), el.reference_center)
        AND pay.req_date BETWEEN TO_DATE('2023-01-17','YYYY-MM-DD') AND TO_DATE('2023-01-18','YYYY-MM-DD')
        --AND ar.customerid = 1015
        AND prod.globalid = 'REPRESENTATION_REJECTION_FEE'
        AND el.time_stamp - (5*1000) < art.entry_time
        AND NOT EXISTS
        (
                SELECT
                        cn.*
                FROM vivagym.credit_note_lines_mt cnl
                JOIN vivagym.credit_notes cn ON cnl.center = cn.center AND cnl.id = cn.id
                WHERE 
                        cnl.person_center = ar.customercenter
                        AND cnl.person_id = ar.customerid
                        AND (cn.employee_center, cn.employee_id) IN ((100,803),(100,605))
                        AND cn.entry_time > DATETOLONGC(TO_CHAR(TO_DATE('2023-01-18','YYYY-MM-DD'),'YYYY-MM-DD HH24:MI'), cn.center)
                        AND cn.text = 'Recargo devolucion devuelto'
        )
        AND art.status NOT IN ('CLOSED')