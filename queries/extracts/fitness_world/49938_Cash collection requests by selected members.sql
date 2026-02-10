-- The extract is extracted from Exerp on 2026-02-08
--  
Select
cr.ref as               paymentrequest2,
       decode(cr.STATE,-1,'NOT_SENT',0,'NEW',1,'SENT',2,'PAID',3,'CANCELLED',4,'RECEIVED','UNKNOWN')as state,
prs.OPEN_AMOUNT as openamount,
cr.REQ_AMOUNT as requestedamount,
ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID,
cr.REQ_DELIVERY as fileid,
cr.REQ_DATE
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

WHERE 
    
(ar.CUSTOMERCENTER,ar.CUSTOMERID) in (:person)

and

REQ_DATE between (:datefrom) and (:dateto) 