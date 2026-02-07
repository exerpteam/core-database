SELECT

ar.customercenter||'p'||ar.customerid AS personid
,SUM(art.amount) AS transaction_balance

FROM

ar_trans art

JOIN account_receivables ar
ON ar.center = art.center
AND ar.id = art.id

WHERE

art.employeecenter = 990
AND art.employeeid = 2660
AND art.entry_time > (CAST((CURRENT_DATE-TO_DATE('1-1-1970','MM-DD-YYYY')) AS BIGINT)) * 24 * 3600 * 1000
-- AND art.entry_time > CAST((:EntryStartTime-TO_DATE('1-1-1970','MM-DD-YYYY')) AS BIGINT) * 24 * 3600 * 1000
    -- Can configure a date parameter if audting for changes not made on the current date
GROUP BY 1

HAVING SUM(art.amount) != 0