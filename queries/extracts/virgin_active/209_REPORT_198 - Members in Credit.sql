-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     ar.BALANCE,
     p.CENTER || 'p' ||  p.ID pid,
         p.fullname
 FROM
     ACCOUNT_RECEIVABLES ar
 join PERSONS p on p.CENTER = ar.CUSTOMERCENTER and p.ID = ar.CUSTOMERID
 WHERE
     ar.BALANCE > 0
     AND ar.AR_TYPE = 4
