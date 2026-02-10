-- The extract is extracted from Exerp on 2026-02-08
-- ST-9865
 SELECT
 "PERSON_ID",
 "ACCOUNT_TYPE",
 "GL_ACCOUNT",
 "AGE",
 SUM(UNSETTLED_AMOUNT)
  FROM
 (
 SELECT
   cp.center || 'p' || cp.id AS "PERSON_ID",
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
         WHEN longtodatec(art.TRANS_TIME, art.center) > cast(:cutdate as date)
         THEN 'FUTURE'
         WHEN art.DUE_DATE IS NULL
         OR  art.DUE_DATE > cast(:cutdate as date)
         THEN 'NOT_DUE'
         WHEN MONTHS_BETWEEN(cast(:cutdate as date),art.DUE_DATE) > 12
         THEN '12+'
         ELSE COALESCE(cast(FLOOR(MONTHS_BETWEEN(cast(:cutdate as date),art.DUE_DATE)) as text),'NOT_DUE')
     END             AS "AGE",
     art.UNSETTLED_AMOUNT
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
 AND longtodate(art.ENTRY_TIME) <= cast(:cutdate as date)
 ) t
 GROUP BY
 "PERSON_ID",
 "ACCOUNT_TYPE",
 "GL_ACCOUNT",
 "AGE"
