-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid, 
    ar.balance, 
    ar.ar_type,
    cc.amount as cc_amount,
    cc.CURRENTSTEP,
    cc.CURRENTSTEP_DATE,
    cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
    longToDate(cc.CLOSED_DATETIME) as Closedate,
s.end_date
FROM 
CASHCOLLECTIONCASES cc    

JOIN 
ACCOUNT_RECEIVABLES ar on             
        ar.CUSTOMERCENTER = cc.PERSONCENTER
        and ar.CUSTOMERID = cc.PERSONID
JOIN
	PERSONS p on p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID
join
subscriptions s

on 
s.owner_center = p.center
and
s.owner_id = p.id

Where
   p.CENTER IN (:scope)
and
cc.closed = 0  

and

ar.balance <= 0

--and

--p.status in (1,3)

--and

--s.state in (2,4)