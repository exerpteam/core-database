-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid, 
    ar.balance, cc.amount as cc_amount,
    cc.CURRENTSTEP,
    cc.CURRENTSTEP_DATE,
    cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
    longToDate(cc.CLOSED_DATETIME)
FROM 
    ACCOUNT_RECEIVABLES ar 
JOIN 
    CASHCOLLECTIONCASES cc on             
        ar.CUSTOMERCENTER = cc.PERSONCENTER
        and ar.CUSTOMERID = cc.PERSONID
JOIN
	PERSONS p on p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID
where cc.CURRENTSTEP = 7


