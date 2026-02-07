SELECT 
c.country,
ar.customercenter ||'p'|| ar.customerid AS memberid,
ar.balance, 
CASE ar.AR_TYPE
    WHEN 1 THEN 'cash_account'
    WHEN 4 THEN 'payment_account'
    WHEN 5 THEN 'debt_account'
    WHEN 6 THEN 'installment_plan_account'
  END AS ar_type, 
MAX(s.end_date) AS latest_end_date
FROM account_receivables ar 
JOIN persons p on ar.customercenter = p.center AND ar.customerid = p.id
JOIN subscriptions s on s.owner_center = p.center AND s.owner_id = p.id
JOIN centers c ON c.id = ar.center
WHERE p.status = 2
AND ar.center IN (:scope)
AND ar.ar_type IN (1,4,5,6)
AND ar.balance != 0
AND NOT EXISTS
    (
        SELECT
           r.center ||'p'|| r.id
        FROM
            persons op
                
        JOIN
            relatives r
        ON
            r.center = op.center
        AND r.id = op.id
               
        where r.rtype = 12
        and r.STATUS = 1
            and  op.center = p.center
              and op.id = p.id)
GROUP BY ar.customercenter, ar.customerid, ar.balance, ar.AR_TYPE, c.country
HAVING MAX(s.end_date) + interval '36 months' <= TO_DATE(getcentertime(ar.customercenter),'YYYY-MM-DD')