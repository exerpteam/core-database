SELECT *
FROM vivagym.invoices i
LEFT JOIN vivagym.invoice_lines_mt il
                ON il.center = i.center
                AND il.id = i.id
LEFT JOIN vivagym.persons p
                ON p.center = il.person_center
                AND p.ID = il.person_id
--WHERE i.receipt_id  = 20000 AND i.center = 608
WHERE p.external_id ='100440974'
