-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.CENTER || 'p' || p.ID pid ,
     p.FULLNAME              company_name ,
     ar.BALANCE ,
     CASE ch.NAME WHEN 'PURE GYM LIMITED' THEN 'Direct Debit' WHEN 'PURE GYM INVOICE' THEN 'INVOICE' ELSE 'UNKNOWN' END
                               Payment_Method ,
     SUM(art.UNSETTLED_AMOUNT) OLD_DEBT_TOTAL_AMOUNT ,
     SUM(
         CASE
             WHEN NOT (art.DUE_DATE IS NOT NULL
                 AND art.DUE_DATE < CURRENT_TIMESTAMP
                 AND art.COLLECTED = 1)
             THEN art.UNSETTLED_AMOUNT
             ELSE 0
         END) NEW_DEBT ,
     SUM(
         CASE
             WHEN TRUNC(CURRENT_TIMESTAMP) - art.DUE_DATE BETWEEN 1 AND 30
             AND (art.DUE_DATE IS NOT NULL
                 AND art.DUE_DATE < CURRENT_TIMESTAMP
                 AND art.COLLECTED = 1)
             THEN art.UNSETTLED_AMOUNT
             ELSE 0
         END) DEBT_0_TO_30_DAYS ,
     SUM(
         CASE
             WHEN TRUNC(CURRENT_TIMESTAMP) - art.DUE_DATE BETWEEN 31 AND 60
             AND (art.DUE_DATE IS NOT NULL
                 AND art.DUE_DATE < CURRENT_TIMESTAMP
                 AND art.COLLECTED = 1)
             THEN art.UNSETTLED_AMOUNT
             ELSE 0
         END) DEBT_30_TO_60_DAYS ,
     SUM(
         CASE
             WHEN TRUNC(CURRENT_TIMESTAMP) - art.DUE_DATE > 60
             AND (art.DUE_DATE IS NOT NULL
                 AND art.DUE_DATE < CURRENT_TIMESTAMP
                 AND art.COLLECTED = 1)
             THEN art.UNSETTLED_AMOUNT
             ELSE 0
         END) DEBT_OLDER_THEN_60_DAYS
 FROM
     PERSONS p
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.CENTER
 AND ar.CUSTOMERID = p.ID
 AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
 AND pac.id = ar.ID
 LEFT JOIN
     PAYMENT_AGREEMENTS agr
 ON
     agr.CENTER = pac.ACTIVE_AGR_CENTER
 AND agr.ID = pac.ACTIVE_AGR_ID
 AND agr.SUBID = pac.ACTIVE_AGR_SUBID
 LEFT JOIN
     CLEARINGHOUSES ch
 ON
     ch.id = agr.CLEARINGHOUSE
 JOIN
     AR_TRANS art
 ON
     art.CENTER = ar.CENTER
 AND art.ID = ar.ID
 AND art.UNSETTLED_AMOUNT !=0
 WHERE
     p.SEX = 'C'
 AND ar.center IN ($$scope$$)
 GROUP BY
     p.CENTER ,
     p.FULLNAME ,
     p.ID ,
     ar.BALANCE ,
     CASE ch.NAME WHEN 'PURE GYM LIMITED' THEN 'Direct Debit' WHEN 'PURE GYM INVOICE' THEN 'INVOICE' ELSE 'UNKNOWN' END
