-- This is the version from 2026-02-05
-- EC-7405
SELECT
    ss.owner_center ||'p'|| ss.owner_id AS "MEMBERID",
    art.amount,
    art.unsettled_amount,
    art.collected_amount,
    ss.sales_date,
    art.due_date,
    art.text,
    art.status
FROM
    subscriptions s
JOIN
    subscription_sales ss
ON
    ss.owner_center = s.owner_center
AND ss.owner_id = s.owner_id
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ss.owner_center = ar.customercenter
AND ss.owner_id = ar.customerid
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
WHERE
s.state IN (2,4) -->ACTIVE & FROZEN<--
AND s.end_date is NULL
AND art.due_date <= ss.sales_date
AND art.STATUS IN ('OPEN',
                   'NEW')
AND s.owner_center in (:scope)