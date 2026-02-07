SELECT DISTINCT
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
WHERE p.status = 2
AND ar.center IN (:scope)
AND ar.balance > 0 
AND ar.balance < 5
AND ar.ar_type IN (1,4,5,6)
GROUP BY ar.customercenter, ar.customerid, ar.balance, ar.AR_TYPE, p.center
HAVING CAST(ADD_MONTHS(MAX(s.end_date), 6) AS VARCHAR(20)) <= CAST(getcentertime(p.center) AS VARCHAR(20))