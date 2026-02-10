-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    act.center,
    TRUNC(longtodate(act.trans_time), 'MM') AS month,
    COUNT(*) AS transaction_count
FROM account_trans act
JOIN accounts deb
    ON act.debit_accountcenter = deb.center
   AND act.debit_accountid     = deb.id
WHERE deb.external_id = '1683'
  AND longtodate(act.trans_time) >= DATE '2025-01-01'
  AND longtodate(act.trans_time) <  DATE '2026-01-01'
GROUP BY
    act.center,
    TRUNC(longtodate(act.trans_time), 'MM')
ORDER BY
    act.center,
    month