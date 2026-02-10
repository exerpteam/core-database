-- The extract is extracted from Exerp on 2026-02-08
-- EC-4773
 SELECT
     "CENTER",
     "PERSON_NO",
     "PERSON_NAME",
     "ACCOUNT_TYPE",
     "LAST_TRANSACTION_TIME",
     "GL_ACCOUNT",
     "AGE_MONTHS",
     "ACCOUNT_BALANCE",
     SUM(UNSETTLED_AMOUNT)
 FROM
     (
         SELECT
             cp.center                                               AS "CENTER" ,
             cp.center || 'p' || cp.id                               AS "PERSON_NO",
             p.firstname || ' ' || p.middlename || ' ' || p.lastname AS "PERSON_NAME",
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
             longtodate(ar.last_trans_time)                      AS "LAST_TRANSACTION_TIME" ,
             ac.EXTERNAL_ID AS "GL_ACCOUNT",
         -- TO_CHAR(FLOOR(MONTHS_BETWEEN(sysdate,art.trans_time)))  AS "AGE",
         FLOOR(MONTHS_BETWEEN(current_date, cast(LONGTODATE(AR.LAST_TRANS_TIME)as date))) AS "AGE_MONTHS",
             ar.balance AS "ACCOUNT_BALANCE",
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
         AND art.center IN ($$scope$$)
           AND  art.due_date >= $$duedate$$
        and  longtodate(art.entry_time) >= $$creationdate$$
 AND ar.balance <> 0
       ) t1
 GROUP BY
     "CENTER",
     "PERSON_NO",
     "PERSON_NAME",
     "ACCOUNT_TYPE",
     "LAST_TRANSACTION_TIME",
     "GL_ACCOUNT",
     "AGE_MONTHS",
     "ACCOUNT_BALANCE"
