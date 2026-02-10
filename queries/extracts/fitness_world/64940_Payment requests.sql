-- The extract is extracted from Exerp on 2026-02-08
--  
select
ar.customercenter ||'p'|| ar.customerid,
pr.CENTER,
pr.ID,
pr.SUBID,
CASE pr.STATE
    WHEN 1 THEN 'NEW'
    WHEN 2 THEN 'SENT'
    WHEN 3 THEN 'DONE'
    WHEN 4 THEN 'DONE MANUALLY'
    WHEN 5 THEN 'FAILED, REJECTED BY CLEARINGHOUSE'
    WHEN 6 THEN 'FAILED, BANK REJECTED'
    WHEN 7 THEN 'FAILED, REJECTED BY DEBTOR'
    WHEN 8 THEN 'CANCELLED'
    WHEN 12 THEN 'FAILED, COULD NOT BE SENT'
    WHEN 17 THEN 'FAILED, PAYMENT REVOKED'
    WHEN 18 THEN 'DONE PARTIALLY'
    WHEN 19 THEN 'FAILED, NOT SUPPORTED'
    ELSE 'UNKNOWN'
END AS PAYMENT_REQUEST_STATE,
prs.PAID_STATE,
prs.requested_amount,
prs.OPEN_AMOUNT,
pr.REQ_DATE
from payment_requests pr
left join payment_request_specifications prs
ON PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID
left join account_receivables ar
ON pr.CENTER = ar.CENTER AND pr.ID = ar.ID
WHERE
pr.STATE = 2 
AND prs.PAID_STATE not in ('CANCELLED','CLOSED')
AND prs.OPEN_AMOUNT > 0 
AND pr.REQ_DATE between :fromdate AND :toDate
AND pr.CENTER in (:scope)