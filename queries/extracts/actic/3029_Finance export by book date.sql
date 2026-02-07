select 
    sums.gl_export_batch_id,
c.EXTERNAL_ID,
    sums.account, book_date,
    SUM(sums.amount) AS amount
from
(
select gl_export_batch_id, center, debit_account_external_id as account, amount as amount, book_date from aggregated_transactions
where center in (:Scope) and book_date >= (:FromDate) and book_date <= (:ToDate) 

union all

select gl_export_batch_id, center, credit_account_external_id as account, amount * -1 as amount, book_date from aggregated_transactions
where center in (:Scope) and book_date >= (:FromDate) and book_date <= (:ToDate) 

union all

select gl_export_batch_id, center, debit_vat_account_external_id as account, vat_amount as amount, book_date from aggregated_transactions
where center in (:Scope) and book_date >= (:FromDate) and book_date <= (:ToDate) 

union all

select gl_export_batch_id, center, credit_vat_account_external_id as account, vat_amount * -1 as amount, book_date from aggregated_transactions
where center in (:Scope) and book_date >= (:FromDate) and book_date <= (:ToDate) 
) sums
JOIN CENTERS c on c.id = sums.center
LEFT JOIN GL_EXPORT_BATCHES batch
ON
    batch.ID = sums.gl_export_batch_id
LEFT JOIN EXCHANGED_FILE exFile
ON
    batch.EXCHANGED_FILE_ID = exFile.ID
WHERE
    center < 200
    AND exFile.STATUS = 'GENERATED'
    AND sums.amount <> 0

group by gl_export_batch_id, c.EXTERNAL_ID, account, book_date

order by c.EXTERNAL_ID, gl_export_batch_id