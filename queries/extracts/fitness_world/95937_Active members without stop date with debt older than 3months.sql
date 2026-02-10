-- The extract is extracted from Exerp on 2026-02-08
-- EC-7405
select 
s.owner_center ||'p'|| s.owner_id AS "MEMBERID",
art.amount,
art.unsettled_amount,
art.collected_amount,
art.due_date,
art.text,
art.status

FROM subscriptions s    
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    s.owner_center = ar.customercenter
    and s.owner_id = ar.customerid    	
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
WHERE
art.STATUS IN ('OPEN', 'NEW')
AND art.due_date <= add_months(current_date, -3)
AND s.state = 2 -->ACTIVE<--
AND s.end_date is NULL
AND s.owner_center in (:scope)