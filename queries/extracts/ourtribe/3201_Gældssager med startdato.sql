Select
  t1.memberid as medlemsnummer, 
  t1.cc_amount as gældsbeløb,
     t1.STARTDATE as "startdato for gældssag",
sum(t1.amount) as "beløb rykkergebyr"

from

(
SELECT distinct
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID as memberid, 
    --ar.balance, 
   -- ar.ar_type,
    cc.amount as cc_amount,
   -- cc.CURRENTSTEP,
 --   cc.CURRENTSTEP_DATE,
  --  cc.CASHCOLLECTIONSERVICE,
    cc.STARTDATE,
longtodate(art.trans_time) as bookdate,
  --  longToDate(cc.CLOSED_DATETIME) as Closedate,
--s.end_date,
art.text,
art.amount
FROM 
CASHCOLLECTIONCASES cc    

JOIN 
ACCOUNT_RECEIVABLES ar on             
        ar.CUSTOMERCENTER = cc.PERSONCENTER
        and ar.CUSTOMERID = cc.PERSONID
JOIN	PERSONS p 
	
on p.center= ar.CUSTOMERCENTER and p.id=ar.CUSTOMERID
join
subscriptions s

on 
s.owner_center = p.center
and
s.owner_id = p.id

join cashcollection_requests cr
on
cr.center = cc.center
and
cr.id = cc.id

join payment_requests pr
on
pr.center = cr.payment_request_center
and
pr.id = cr.payment_request_id
and
pr.subid = cr.payment_request_subid

join PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID

left JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.center
AND art.PAYREQ_SPEC_ID = prs.id
AND prs.SUBID = art.PAYREQ_SPEC_SUBID
and art.text = 'Payment Reminder'



Where
 (p.CENTER,p.id) in (:members)
and
cc.closed = 0  

) t1

where
t1.amount is not null


group by
t1.text,
t1.memberid,
t1.cc_amount,
t1.startdate