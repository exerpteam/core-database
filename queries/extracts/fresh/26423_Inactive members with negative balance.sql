-- The extract is extracted from Exerp on 2026-02-08
-- EC-8523
SELECT
    c.country,
    ar.customercenter ||'p'|| ar.customerid AS memberid,
    ROUND(ar.balance, 2)                    AS balance,
    CASE ar.AR_TYPE
        WHEN 1
        THEN 'cash_account'
        WHEN 4
        THEN 'payment_account'
        WHEN 5
        THEN 'debt_account'
        WHEN 6
        THEN 'installment_plan_account'
    END             AS ar_type,
    MAX(s.end_date) AS latest_end_date
FROM
    account_receivables ar
JOIN
    persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    centers c
ON
    c.id = ar.center
WHERE
    p.status = 2
AND ar.center IN (:scope)
AND ar.balance < 0
AND ar.state=0
AND ( (
            c.country IN ('SE',
                          'DK',
                          'NO')
        AND ar.balance >= -50 )
    OR  (
            c.country = 'FI'
        AND ar.balance >= -5) )
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
GROUP BY
    ar.customercenter,
    ar.customerid,
    ar.balance,
    ar.AR_TYPE,
    c.country
HAVING
    MAX(s.end_date) + interval '6 months' <= TO_DATE(getcentertime(ar.customercenter),'YYYY-MM-DD')