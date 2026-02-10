-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
ar.customercenter ||'p'|| ar.customerid AS memberid,
p.firstname,
p.lastname,
p.state,
ar.balance, 
CASE ar.AR_TYPE
    WHEN 1 THEN 'cash_account'
    WHEN 4 THEN 'payment_account'
  END AS ar_type, 
MAX(s.end_date) AS latest_end_date
FROM account_receivables ar 
JOIN persons p on ar.customercenter = p.center AND ar.customerid = p.id
JOIN subscriptions s on s.owner_center = p.center AND s.owner_id = p.id
WHERE p.status = 2
AND ar.center IN (:scope)
AND ar.balance < 100
AND ar.balance > -100
AND ar.balance != 0
AND ar.ar_type IN (1,4)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            relatives r
        WHERE
            r.center = p.center
        AND r.id = p.id
        AND r.rtype = 12
        AND r.status = 1 )
GROUP BY ar.customercenter, ar.customerid, ar.balance, ar.AR_TYPE, p.center, p.firstname, p.lastname, p.state
HAVING CAST(ADD_MONTHS(MAX(s.end_date), 6) AS VARCHAR(20)) <= CAST(getcentertime(p.center) AS VARCHAR(20))