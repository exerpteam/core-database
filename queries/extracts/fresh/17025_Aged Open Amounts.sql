-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
   cp.center as "CENTER",
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
     CASE
         WHEN art.TRANS_TIME > datetolong(to_char(getcentertime(art.center)::date, 'YYYY-MM-dd HH24:MI'))::bigint
         THEN 'FUTURE'
         WHEN art.DUE_DATE IS NULL
         OR  art.DUE_DATE > CURRENT_DATE
         THEN 'NOT_DUE'
         WHEN FLOOR(MONTHS_BETWEEN(trunc(getcentertime(art.center)::date),art.DUE_DATE)) > 12
         THEN '12+'
         ELSE COALESCE(FLOOR(MONTHS_BETWEEN(trunc(getcentertime(art.center)::date),art.DUE_DATE))::numeric::text,'NOT DUE')
     END             AS "AGE",
     SUM(art.AMOUNT) AS "OPEN_AMOUNT"
 FROM
     AR_TRANS art
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.center = art.center
 AND ar.id = art.id
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
     art.STATUS IN ('OPEN',
                    'NEW')
 AND art.center IN (:scope)
 GROUP BY
     cp.center ,
     ar.AR_TYPE,
     /* CASE
     WHEN ar.AR_TYPE = 1
     THEN 'CASH'
     WHEN ar.AR_TYPE = 4
     THEN 'PAYMENT'
     WHEN ar.AR_TYPE = 5
     THEN 'DEBT'
     WHEN ar.AR_TYPE = 6
     THEN 'INSTALLMENT'
     END ,*/
     ac.EXTERNAL_ID ,
     CASE
         WHEN art.TRANS_TIME > datetolong(to_char(getcentertime(art.center)::date, 'YYYY-MM-dd HH24:MI'))::bigint
         THEN 'FUTURE'
         WHEN art.DUE_DATE IS NULL
         OR  art.DUE_DATE > CURRENT_DATE
         THEN 'NOT_DUE'
         WHEN FLOOR(MONTHS_BETWEEN(trunc(getcentertime(art.center)::date),art.DUE_DATE)) > 12
         THEN '12+'
         ELSE COALESCE(FLOOR(MONTHS_BETWEEN(trunc(getcentertime(art.center)::date),art.DUE_DATE))::numeric::text,'NOT DUE')
     END
