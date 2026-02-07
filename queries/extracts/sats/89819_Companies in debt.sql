select
t1.company as companyid,
t1.fullname as "Name of Company",
sum(t1.AMOUNT)as "total debt"

from
(

 SELECT
     ar.CUSTOMERCENTER || 'p' ||    ar.CUSTOMERID as "company",
     p.FULLNAME,
  --   longToDate(art.TRANS_TIME) TRANS_TIME,
     art.unsettled_amount as amount,
     art.DUE_DATE
    -- art.INFO,
   --  art.TEXT
     
 FROM
     AR_TRANS art
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = art.CENTER
     AND ar.ID = art.ID
 join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
 and p.sex = 'C'
 WHERE
     ar.AR_TYPE in (5,4)
     and ar.CENTER in (:scope)
     and art.unsettled_amount < 0
     and art.DUE_DATE < current_date )t1
     
group by
t1.company,
t1.fullname