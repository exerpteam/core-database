-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     cp.center||'p'||cp.id as "MEMBERID",
CASE 
WHEN cp.STATUS = 0 THEN 'LEAD' 
WHEN cp.STATUS = 1 THEN 'ACTIVE' 
WHEN cp.STATUS = 2 THEN 'INACTIVE' 
WHEN cp.STATUS = 3 THEN 'TEMPORARYINACTIVE' 
WHEN cp.STATUS = 4 THEN 'TRANSFERRED' 
WHEN cp.STATUS = 5 THEN 'DUPLICATE' 
WHEN cp.STATUS = 6 THEN 'PROSPECT' 
WHEN cp.STATUS = 7 THEN 'DELETED' 
WHEN cp.STATUS = 8 THEN 'ANONYMIZED' 
WHEN cp.STATUS = 9 THEN 'CONTACT' ELSE 'Undefined' END AS "PERSON_STATUS",
     CASE
         WHEN ar.AR_TYPE = 1
         THEN 'CASH'
         WHEN ar.AR_TYPE = 4
         THEN 'PAYMENT'
         WHEN ar.AR_TYPE = 5
         THEN 'DEBT'
         WHEN ar.AR_TYPE = 6
         THEN 'INSTALLMENT'
     END            AS "ACCOUNT_TYPE",
          ar.BALANCE,
t2.unsettled_amount as "sum transactions new"
 FROM
     ACCOUNT_RECEIVABLES ar

 left JOIN
     PERSONS p
 ON
     p.center = ar.CUSTOMERCENTER
 AND p.id = ar.CUSTOMERID
 LEFT JOIN
     PERSONS cp
 ON
     cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
 AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
left join
(
 select
t1.CUSTOMERCENTER,
t1.CUSTOMERID,
t1.entry_time,
t1.text,
t1.unsettled_amount


from
(
Select
sum(art.unsettled_amount),
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
art.text,
art.amount,
art.unsettled_amount,
longtodate(art.entry_time) as entry_time,
art.status

from ar_trans art

join ACCOUNT_RECEIVABLES ar
on
ar.center = art.center
and
ar.id = art.id

where
ar.center IN (:scope)   
--ar.CUSTOMERCENTER = 510
--and
--ar.CUSTOMERID = 73252
AND ar.AR_TYPE = 1
and art.status in ('NEW') 
and longtodate(art.entry_time) between '2025-08-25' and '2025-08-27'
AND ar.BALANCE < 0 

group by
art.unsettled_amount,
ar.CUSTOMERCENTER,
ar.CUSTOMERID,
art.text,
art.amount,
art.entry_time,
art.status

)t1
 )t2

on t2.CUSTOMERCENTER = ar.CUSTOMERCENTER
and t2.CUSTOMERID = ar.CUSTOMERID
 
 
 WHERE
   ar.center IN (:scope)
   and cp.STATUS in (1,3)
AND ar.AR_TYPE = 4
AND ar.BALANCE < 0 