-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(to_char(to_date(:FromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromdate,
                datetolongc(to_char(to_date(:ToDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 as todate,
                c.id
        FROM vivagym.centers c
        WHERE
                c.country = 'ES'
AND c.ID IN (:sCOPE)
),
invoices_total AS
(
        SELECT
                i.center,
                SUM(il.total_amount) AS totalamount
        FROM vivagym.invoices i
        JOIN params par ON i.center = par.id
        JOIN vivagym.invoice_lines_mt il ON i.center = il.center AND i.id = il.id
        WHERE
                il.total_amount <> 0
				AND i.text NOT IN ('Converted subscription invoice')
                AND i.entry_time between par.fromDate AND par.todate
        GROUP BY
                i.center
),
creditnotes_total AS
(
        SELECT
                cn.center,
                SUM(cnl.total_amount) AS totalamount
        FROM vivagym.credit_notes cn
        JOIN params par ON cn.center = par.id
        JOIN vivagym.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
        WHERE
                cnl.total_amount <> 0
                AND cn.entry_time between par.fromDate AND par.todate
        GROUP BY
                cn.center
)
SELECT
        c.id,
        c.name,
        it.totalamount AS invoice_total_amount,
        cnt.totalamount AS creditnotes_total_amount,
        it.totalamount - cnt.totalamount AS total_sales
FROM vivagym.centers c
JOIN invoices_total it ON c.id = it.center
LEFT JOIN creditnotes_total cnt ON c.id = cnt.center
ORDER BY 2
