-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    act.center,
    date_trunc(
        'month',
        (longtodate(act.trans_time) AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Jakarta'
    ) AS month,
    COUNT(*) AS transaction_count
FROM account_trans act
JOIN accounts deb
    ON act.debit_accountcenter = deb.center
   AND act.debit_accountid     = deb.id
WHERE deb.external_id in ('258001-01','258001-25')
  AND ((longtodate(act.trans_time) AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Jakarta')
        >= timestamp '2025-01-01 00:00:00'
  AND ((longtodate(act.trans_time) AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Jakarta')
        <  timestamp '2026-01-01 00:00:00'
GROUP BY
    act.center,
    date_trunc(
        'month',
        (longtodate(act.trans_time) AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Jakarta'
    )
ORDER BY
    act.center,
    month