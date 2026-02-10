-- The extract is extracted from Exerp on 2026-02-08
-- EC-7859
SELECT
   cp.center as "CENTER",
   cp.FULLNAME,
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
     ac.EXTERNAL_ID AS "GL_ACCOUNT",
     ar.BALANCE,
t2.entry_time as "last open trans entry_time" ,
t2.text as "last open trans text",
t2.unsettled_amount as "last open trans open amount"
 FROM
     ACCOUNT_RECEIVABLES ar
 LEFT JOIN
     ACCOUNTS ac
 ON
     ac.center = ar.ASSET_ACCOUNTCENTER
 AND ac.id = ar.ASSET_ACCOUNTID
 LEFT JOIN
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
rank() over(partition by ar.CUSTOMERCENTER ||'p'||ar.CUSTOMERID ORDER BY art.entry_time DESC) as rnk,
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
and art.status in ('OPEN','NEW') 
AND ar.BALANCE != 0 



)t1
where rnk = 1 )t2

on t2.CUSTOMERCENTER = ar.CUSTOMERCENTER
and t2.CUSTOMERID = ar.CUSTOMERID
 
 
 WHERE
   ar.center IN (:scope)
AND ar.AR_TYPE = 1
AND ar.BALANCE != 0 