-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    act.center,
    date_trunc(
        'month',
        longtodate(act.trans_time) AT TIME ZONE 'UTC'
    ) AS month,
    COUNT(*) AS transaction_count
FROM account_trans act
JOIN accounts deb
    ON act.debit_accountcenter = deb.center
   AND act.debit_accountid     = deb.id
WHERE deb.external_id = '58650'
  AND (longtodate(act.trans_time) AT TIME ZONE 'UTC')
        >= timestamptz '2025-01-01 00:00:00+00'
  AND (longtodate(act.trans_time) AT TIME ZONE 'UTC')
        <  timestamptz '2026-01-01 00:00:00+00'
GROUP BY
    act.center,
    date_trunc(
        'month',
        longtodate(act.trans_time) AT TIME ZONE 'UTC'
    )
ORDER BY
    act.center,
    month