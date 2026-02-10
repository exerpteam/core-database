-- The extract is extracted from Exerp on 2026-02-08
--  
 select
         ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS "PERSON_ID",
         TO_CHAR(longtodatec(art.trans_time, art.center) , 'YYYY-MM-dd HH24:MI') as "TRANSTIME",
         TO_CHAR(longtodatec(art.ENTRY_TIME, art.center) , 'YYYY-MM-dd HH24:MI') as "ENTRYTIME",
         art.AMOUNT as "AMOUNT",
         CASE  art.EMPLOYEEID  WHEN 14202 THEN  'APP'  WHEN 3202 THEN  'WEB'  ELSE 'Err' END AS "EMP_ID",
         art.info as "INFO",
         art.text as "TEXT",
         art.REF_TYPE as "REFTYPE",
         CASE    WHEN art.REF_SUBID IS NULL THEN  art.REF_CENTER || 'inv' || art.REF_ID  ELSE art.REF_CENTER || 'acc' || art.REF_ID || 'tr' || art.REF_SUBID END AS "TRANS_ID",
         art.STATUS as "STATUS"
 from
                 ar_trans art
         JOIN
                 ACCOUNT_RECEIVABLES AR
         ON
                 AR.CENTER = art.CENTER
 AND AR.ID = art.ID
 where
         art.employeecenter = 100
 AND art.employeeid in (14202,3202)
         AND LongTODate(art.entry_time) >= $$FromDate$$
         AND LongTODate(art.entry_time) <= $$ToDate$$
