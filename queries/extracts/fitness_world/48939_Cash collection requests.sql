-- This is the version from 2026-02-05
--  
SELECT
	t1.paymentrequest2,
t1.state,
t1.openamount,
t1.requestedamount,
t1.CUSTOMERCENTER || 'p' || t1.CUSTOMERID as PersonId,
t1.fileid,
t1.BALANCE,
t1.ar_type,
t2.BALANCE AS DebtAccountBalance
FROM
(
SELECT 
cr.ref as               paymentrequest2,
       decode(cr.STATE,-1,'NOT_SENT',0,'NEW',1,'SENT',2,'PAID',3,'CANCELLED',4,'RECEIVED','UNKNOWN')as state,
prs.OPEN_AMOUNT as openamount,
cr.REQ_AMOUNT as requestedamount,
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
cr.REQ_DELIVERY as fileid,
ar.BALANCE,
ar.ar_type
-- cc.CC_AGENCY_AMOUNT
From
    CASHCOLLECTION_REQUESTS cr
Join
    PAYMENT_REQUEST_SPECIFICATIONS prs

ON    
     cr.ref = prs.ref
       
left Join
    ACCOUNT_RECEIVABLES ar

ON
prs.CENTER = ar.CENTER and prs.id = ar.ID

-- left Join CASHCOLLECTIONCASES cc
-- on
-- cc.PERSONCENTER = ar.CUSTOMERCENTER and cc.PERSONID = ar.CUSTOMERID

WHERE 
  
cr.REQ_DELIVERY in (:fileid)
) t1
LEFT JOIN
(
	SELECT
		ar.CUSTOMERCENTER,
		ar.CUSTOMERID,
		ar.BALANCE
	FROM ACCOUNT_RECEIVABLES ar
	WHERE
		ar.AR_TYPE = 5
		AND ar.BALANCE != 0
) t2
ON t1.CUSTOMERCENTER = t2.CUSTOMERCENTER AND t1.CUSTOMERID = t2.CUSTOMERID