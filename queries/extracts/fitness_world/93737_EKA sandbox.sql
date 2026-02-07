-- This is the version from 2026-02-05
--  
SELECT 
prs.center ||'p'|| prs.id AS "memberid",
prs.center AS "center",
prs.ref AS "payment_request_ID",
prs.original_due_date AS "payment_request_due_date",
prs.total_invoice_amount AS "amount", 
prs.inv_diff AS "reminder_fees" FROM payment_request_specifications prs
WHERE prs.center = :center