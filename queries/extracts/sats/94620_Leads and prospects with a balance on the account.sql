-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-182) AS cutDate,
              --  (current_timestamp)- 182 AS cutdate,
                c.id 
        FROM
                centers c
        WHERE
                /*c.id in (:scope) and*/ c.country = 'SE'
)



SELECT distinct
   cp.center as "CENTER",
   cp.FULLNAME,
   cp.center||'p'||cp.id,
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
     t2.entry_time as "Last entry date"
  --   (current_timestamp)- 182
     
 FROM
     ACCOUNT_RECEIVABLES ar
join params
on params.id = ar.center     
     
     
join
(
Select
t1.center,
t1.id,
t1.entry_time

from
(
Select
rank() over(partition by ar.CUSTOMERCENTER ||'p'||ar.CUSTOMERID ORDER BY art.entry_time DESC) as rnk,
art.center,
art.id,
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
art.status in ('OPEN','NEW')
--and art.center IN (:scope)
)t1
where rnk = 1 )t2
on 
t2.center = ar.center
and
t2.id = ar.id      
 
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
 WHERE
 --ar.center IN (:scope) and
p.status in (0,6)
and p.sex != 'C'
   and ar.balance != 0
   and t2.entry_time < params.cutdate