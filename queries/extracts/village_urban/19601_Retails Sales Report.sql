SELECT
        t1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        datetolongc(to_char(to_date(:fromDate,'yyyy-mm-dd'),'yyyy-mm-dd'),c.id) as fromDate,
                        datetolongc(to_char(to_date(:toDate,'yyyy-mm-dd') + interval '1 days','yyyy-mm-dd'),c.id)-1 as toDate,
                        c.id,
                        c.name
                FROM centers c 
                WHERE 
                        c.id IN (:Scope)
        )
        SELECT
                'INVOICE' AS transaction_type,
                par.name AS center_name,
                par.id AS center_id,
TO_CHAR(longtodatec(i.entry_time,i.center),'YYYY-MM-DD HH24:MI') as sales_date,
                pr.name AS product_name,
                pr.globalid AS product_globalid,
                i.employee_center || 'emp' || i.employee_id AS employee_id,
                i.payer_center  || 'p' ||  i.payer_id AS member_id,
                il.quantity,
                il.text AS invoiceline_text,
                il.total_amount
        FROM invoices i
        JOIN params par ON i.center = par.id
        JOIN invoicelines il ON i.center = il.center AND i.id = il.id
        JOIN products pr ON il.productcenter = pr.center AND il.productid = pr.id
        WHERE
                i.entry_time BETWEEN par.fromDate AND par.toDate
                AND pr.ptype = 1
        UNION ALL
        SELECT
                'CREDIT_NOTE' AS transaction_type,
                par.name AS center_name,
                par.id AS center_id,   TO_CHAR(longtodatec(cn.entry_time,cn.center),'YYYY-MM-DD HH24:MI') as sales_date,
                pr.name AS product_name,
                pr.globalid AS product_globalid,
                cn.employee_center || 'emp' || cn.employee_id AS employee_id,
                cn.payer_center  || 'p' ||  cn.payer_id AS member_id,
                cnl.quantity,
                cnl.text AS invoiceline_text,
                cnl.total_amount
        FROM villageurban.credit_notes cn
        JOIN params par ON cn.center = par.id
        JOIN villageurban.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
        JOIN products pr ON cnl.productcenter = pr.center AND cnl.productid = pr.id
        WHERE
                cn.entry_time BETWEEN par.fromDate AND par.toDate
                AND pr.ptype = 1
) t1
ORDER BY 2,4
        