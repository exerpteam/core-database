-- The extract is extracted from Exerp on 2026-02-08
-- TEST
 SELECT
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
     ac.EXTERNAL_ID AS "GL_ACCOUNT",
     ar.BALANCE
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
 WHERE
   ar.center IN (:scope)
   AND ar.AR_TYPE = 5
   AND ar.BALANCE <> 0
