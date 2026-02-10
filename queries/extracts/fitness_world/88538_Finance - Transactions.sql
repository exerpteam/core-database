-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(TO_DATE(:from, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(TO_DATE(:to, 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name,
                                c.country
                                
                       
                                        FROM 
                                                centers c
                                           
            where c.id in (:scope) )  





SELECT
  to_char(longtodateC(atr.entry_time, atr.center), 'DD-MM-YYYY') AS "Book date",
  atr.text AS "Text",
  debit.external_id AS "Debit",
   credit.external_id AS "Credit",
sum(atr.amount)

FROM account_trans atr

join params par
on
par.center_id = atr.center

LEFT JOIN invoice_lines_mt il
  ON atr.center = il.account_trans_center
 AND atr.id = il.account_trans_id
 AND atr.subid = il.account_trans_subid

LEFT JOIN invoices i
  ON i.center = il.center
 AND i.id = il.id

LEFT JOIN accounts debit
  ON debit.center = atr.debit_accountcenter
 AND debit.id = atr.debit_accountid

LEFT JOIN accounts credit
  ON credit.center = atr.credit_accountcenter
 AND credit.id = atr.credit_accountid

LEFT JOIN invoicelines_vat_at_link ivat
  ON ivat.invoiceline_center = il.center
 AND ivat.invoiceline_id = il.id
 AND ivat.invoiceline_subid = il.subid

LEFT JOIN account_trans vat
  ON vat.center = ivat.account_trans_center
 AND vat.id = ivat.account_trans_id
 AND vat.subid = ivat.account_trans_subid

LEFT JOIN accounts debitv
  ON debitv.center = vat.debit_accountcenter
 AND debitv.id = vat.debit_accountid

LEFT JOIN accounts creditv
  ON creditv.center = vat.credit_accountcenter
 AND creditv.id = vat.credit_accountid

LEFT JOIN ar_trans art
  ON art.ref_center = i.center
 AND art.ref_id = i.id
 AND art.ref_type = 'INVOICE'

LEFT JOIN vat_types vt
  ON vat.vat_type_center = vt.center
 AND vat.vat_type_id = vt.id

LEFT JOIN centers c
  ON atr.center = c.id

LEFT JOIN centers debit_center
  ON debit.center = debit_center.id

LEFT JOIN centers credit_center
  ON credit.center = credit_center.id



WHERE
  (credit.external_id IN ('6743') or debit.external_id in ('6743'))
  AND atr.center in (:scope)           
  AND atr.entry_time BETWEEN par.fromdatelong AND par.todatelong

group by
atr.center, 
atr.entry_time,
  atr.text,
  debit.external_id,
  credit.external_id
  

