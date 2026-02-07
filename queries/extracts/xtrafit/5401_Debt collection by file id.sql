SELECT distinct
ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
art.text as text,
art.amount as amount,
longtodate(art.entry_time) as transfer_date,
art.info,
--ar.ar_type,
t1.REQ_DELIVERY





FROM
ACCOUNT_RECEIVABLES ar

join ar_trans art
ON
art.center = ar.center
AND art.id = ar.id

join (
Select distinct
ccc.personcenter,
ccc.personid,
ccc.PERSONCENTER ||'p'|| ccc.PERSONID,
ccr.*


FROM
CASHCOLLECTION_REQUESTS ccr
JOIN
    cashcollectioncases ccc
on
ccc.center = ccr.center
and
ccc.id = ccr.id 

where 
ccr.REQ_DELIVERY in (:fileid) /*and ccr.state in (1)*/) t1

on art.amount = t1.req_amount*-1  
and t1.personcenter = ar.CUSTOMERCENTER and t1.personid = ar.CUSTOMERID



where
ar.ar_type = 5


--and art.text not in ('Transfer between accounts') 
--and art.amount < 0
--and (longtodate(art.entry_time) between t1.req_date-140 and t1.req_date+140)
and t1.ref = art.info