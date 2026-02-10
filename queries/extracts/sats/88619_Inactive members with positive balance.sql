-- The extract is extracted from Exerp on 2026-02-08
-- end date more than 6months ago
50 for NO, SE, DK and 5 for FI
EC-7151
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
AND
(
    (c.country = 'SE' AND ar.balance between 1 and 50)
    OR
    (c.country = 'DK' AND ar.balance between 1 and 50)
    OR
    (c.country = 'NO' AND ar.balance between 1 and 50)
    OR
    (c.country = 'FI' AND ar.balance between 1 and 5)
)
AND ar.ar_type IN (1,4,5,6)
GROUP BY ar.customercenter, ar.customerid, ar.balance, ar.AR_TYPE, c.country
HAVING MAX(s.end_date) + interval '6 months' <= TO_DATE(getcentertime(ar.customercenter),'YYYY-MM-DD')