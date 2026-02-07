SELECT
     ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
 CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS PERSON_STATUS,
     CASE p.SEX WHEN 'C' THEN 'Company' ELSE 'Private' END CUSTOMER_TYPE,
     CASE ar.AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' END account_type,
     longToDate(art.TRANS_TIME) TRANS_TIME,
     art.AMOUNT,
     art.UNSETTLED_AMOUNT,
     art.TEXT,
     ar.CUSTOMERCENTER as "CenterID",
     staff.fullname as "Staff name",
     art.employeecenter ||'emp'|| art.employeeid as "Staff ID",
         art.REF_TYPE
 FROM
     AR_TRANS art
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = art.CENTER
     AND ar.ID = art.ID
 join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.id  = ar.CUSTOMERID

left join employees emp
on emp.center = art.employeecenter
and
emp.id = art.employeeid 

left join persons staff
on
emp.personcenter = staff.center
and
emp.personid = staff.id  
 WHERE
     --art.TRANS_TIME < dateToLong(TO_CHAR(TRUNC(CURRENT_DATE-1),'YYYY-MM-DD') || ' 00:00')
       art.TRANS_TIME <  CAST(datetolong(to_char(getcentertime(art.center)::date - interval '1 day', 'YYYY-MM-dd HH24:MI')) AS bigint)
     AND art.AMOUNT > 0
     AND art.UNSETTLED_AMOUNT != 0
     AND art.CENTER IN ($$scope$$)
 ORDER BY
     ar.CUSTOMERCENTER ,
     ar.CUSTOMERID,ar.AR_TYPE
