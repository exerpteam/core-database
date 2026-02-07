WITH params AS MATERIALIZED
                (
                        SELECT
                                
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where c.id in (:scope) )  



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
t2.entry_time as "last open trans entry_time" ,
t2.text as "last open trans text",
t2.unsettled_amount as "last open trans open amount"
 FROM
     ACCOUNT_RECEIVABLES ar
join params
on
ar.center = params.center_id     
 
 JOIN
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
join params
on
art.center = params.center_id

join ACCOUNT_RECEIVABLES ar
on
ar.center = art.center
and
ar.id = art.id

where

--ar.CUSTOMERCENTER = 510
--and
--ar.CUSTOMERID = 73252
 ar.AR_TYPE = 1
and art.status in ('OPEN','NEW') 
AND ar.BALANCE != 0 



)t1
where rnk = 1 )t2

on t2.CUSTOMERCENTER = ar.CUSTOMERCENTER
and t2.CUSTOMERID = ar.CUSTOMERID
 
 
 WHERE
  cp.STATUS in (0,6)
AND ar.AR_TYPE = 1
AND ar.BALANCE != 0 