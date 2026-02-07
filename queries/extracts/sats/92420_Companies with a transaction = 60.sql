SELECT
p.center ||'p'|| p.id AS company_id,
p.fullname AS company_name,
art.amount,
longtodate(art.entry_time) AS transaction_time,
art.text AS description,
TO_CHAR(longtodate(art.trans_time), 'YYYY-MM-DD') AS book_date
FROM
persons p
JOIN
sats.account_receivables ar
ON
ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
sats.ar_trans art
ON
art.center = ar.center
AND art.id = ar.id
WHERE
p.sex = 'C'
AND p.country NOT IN ('FI')
AND art.amount = 60
AND art.entry_time BETWEEN CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'),
            'YYYY-MM-DD'), p.center) AS BIGINT) 
AND
CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day', 'YYYY-MM-DD'),
            p.center) AS BIGINT)
AND art.ref_type = 'ACCOUNT_TRANS'