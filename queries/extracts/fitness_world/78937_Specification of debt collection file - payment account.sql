-- This is the version from 2026-02-05
--  
SELECT distinct
ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "Person key",
art.CENTER||'ar'||art.ID||'art'||art.SUBID AS "Transaction key",
case
when t1.text is NULL
then art.text
else t1.text
end as text,
art.amount*-1 as amount,
longtodate(art.entry_time) as transfer_date,
art.info,
ar.ar_type,
ccr.REQ_DELIVERY,
t1.text


FROM
ACCOUNT_RECEIVABLES ar

join ar_trans art
ON
art.center = ar.center
AND art.id = ar.id

left JOIN
    cashcollectioncases ccc
ON
    ar.customercenter = ccc.personcenter
    AND ar.customerid = ccc.personid
left join
CASHCOLLECTION_REQUESTS ccr
on
ccc.center = ccr.center
and
ccc.id = ccr.id 
and art.amount = ccr.req_amount and ccr.REQ_DATE between longtodate(art.entry_time)-10 and longtodate(art.entry_time)

--and (art.amount = ccr.REQ_AMOUNT and longtodate(art.entry_time) between  REQ_DATE-10 and REQ_DATE+10)

left join (
select distinct
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
art.text,
art.amount,
longtodate(art.entry_time),
art.info,
ar.ar_type,
art.entry_time


FROM
ACCOUNT_RECEIVABLES ar

join ar_trans art
ON
art.center = ar.center
AND art.id = ar.id    

where
ar.AR_TYPE in (4) and art.amount > 0 and art.text not like 'TransferToCashCollectionAccount%%'

)t1
on
t1.amount = (art.amount*-1)
and
t1.CUSTOMERCENTER = ar.CUSTOMERCENTER
and
t1.CUSTOMERID = ar.CUSTOMERID
and 
longtodate(t1.entry_time) between longtodate(art.entry_time)-1 and longtodate(art.entry_time)

WHERE
 ccr.REQ_DELIVERY is not null
and ccr.REQ_DELIVERY = :fileid