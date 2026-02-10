-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     s.*
 FROM
     (
         WITH
             PARAMS AS
             (
                 SELECT
                     --to_date('2014-05-12')
                     TRUNC(CURRENT_TIMESTAMP, 'DDD') AS currentdate,
                     $$days$$            AS DAYS
                 
             )
         SELECT
             p.center,
             p.id,
             p.status AS Status,
             SUM(
                 CASE
                     WHEN DEBTORS.DUE_DATE + PARAMS.DAYS + 1 <= CURRENTDATE
                     THEN DEBTORS.OpenedAmount
                     ELSE 0
                 END) AS OldDebtAmount,
             SUM(
                 CASE
                     WHEN DEBTORS.DUE_DATE + PARAMS.DAYS + 1 > CURRENTDATE
                     THEN DEBTORS.OpenedAmount
                     ELSE 0
                 END)                                          AS NewerDebtAmount,
             MAX(DEBTORS.DUE_DATE)                             AS LatestOldDebt,
             MIN(DEBTORS.DUE_DATE)                             AS OldestDebt,
             TRUNC(PARAMS.currentdate - MIN(DEBTORS.DUE_DATE))    OldesDebtAge ,
             MAX(pending_pr.REQ_DATE)                          AS PENDING_REQUEST_OR_REP ,
             MAX(latest_pr.REQ_DATE)                           AS LATEST_NORMAL_REQUEST ,
             SUM(DEBTORS.OpenedAmount)                         AS TOTAL_DEBT_AMOUNT ,
             MAX(DEBTORS.AR_BALANCE)                           AS AR_BALANCE
         FROM
             PARAMS ,
             (
                 SELECT
                     ar.CUSTOMERCENTER,
                     ar.CUSTOMERID,
                     ar.CENTER,
                     ar.ID,
                     art.SUBID,
                     art.AMOUNT,
                     art.AMOUNT + COALESCE(SUM(COALESCE(arm.AMOUNT,0)),0) AS OpenedAmount,
                     art.DUE_DATE                               AS DUE_DATE,
                     MAX(cc.AMOUNT)                             AS CC_AMOUNT,
                     MAX(ar.balance)                            AS AR_BALANCE
                 FROM
                     PARAMS
                 CROSS JOIN
                     AR_TRANS art
                 JOIN
                     ACCOUNT_RECEIVABLES ar
                 ON
                     art.CENTER = ar.CENTER
                     AND art.ID = ar.ID
                 JOIN
                     CASHCOLLECTIONCASES cc
                 ON
                     cc.PERSONCENTER = ar.CUSTOMERCENTER
                     AND cc.personid = ar.CUSTOMERID
                     AND cc.CLOSED = 0
                     AND cc.MISSINGPAYMENT = 1
                 LEFT JOIN
                     ART_MATCH arm
                 ON
                     arm.ART_PAID_CENTER = art.CENTER
                     AND arm.ART_PAID_ID = art.ID
                     AND arm.ART_PAID_SUBID = art.SUBID
                     AND (
                         arm.CANCELLED_TIME IS NULL )
                 WHERE
                     art.AMOUNT < 0
                     AND ar.AR_TYPE = 4
                     AND ar.BALANCE < 0
                     AND art.DUE_DATE < CURRENTDATE
                 GROUP BY
                     ar.CUSTOMERCENTER,
                     ar.CUSTOMERID,
                     ar.CENTER,
                     ar.ID,
                     art.SUBID,
                     art.AMOUNT,
                     art.DUE_DATE
                 HAVING
                     -SUM(arm.AMOUNT) <> art.AMOUNT
                     OR SUM(arm.AMOUNT) IS NULL ) DEBTORS
         JOIN
             PERSONS p
         ON
             p.center = DEBTORS.CUSTOMERCENTER
             AND p.id = DEBTORS.CUSTOMERID
                         AND p.PERSONTYPE NOT IN (2,4)
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CUSTOMERCENTER = p.center
             AND ar.CUSTOMERID = p.id
             AND ar.AR_TYPE = 4
         LEFT JOIN
             PAYMENT_ACCOUNTS pac
         ON
             pac.CENTER = ar.CENTER
             AND pac.id = ar.id
         LEFT JOIN
             PAYMENT_AGREEMENTS pa
         ON
             pa.CENTER = pac.ACTIVE_AGR_CENTER
             AND pa.id = pac.ACTIVE_AGR_ID
             AND pa.SUBID = pac.ACTIVE_AGR_SUBID
         LEFT JOIN
             (
                 SELECT
                     pr.center,
                     pr.id,
                     MAX(req_date) AS REQ_DATE
                 FROM
                     PAYMENT_REQUESTS pr,
                     PARAMS
                 WHERE
                     pr.state NOT IN (8)
                     AND pr.REQUEST_TYPE IN (1)
                     AND pr.CLEARINGHOUSE_ID in (201,401,402,601)
                     AND pr.REQ_DATE > PARAMS.CURRENTDATE - PARAMS.DAYS - 1
                 GROUP BY
                     pr.center,
                     pr.id ) latest_pr
         ON
             latest_pr.center = ar.center
             AND latest_pr.id = ar.id
         LEFT JOIN
             (
                 SELECT
                     pr.center,
                     pr.id,
                     MAX(req_date) AS REQ_DATE
                 FROM
                     PAYMENT_REQUESTS pr
                 WHERE
                     pr.state IN (1,
                                  2)
                     AND pr.CLEARINGHOUSE_ID = 1
                 GROUP BY
                     pr.center,
                     pr.id ) pending_pr
         ON
             pending_pr.center = ar.center
             AND pending_pr.id = ar.id
         WHERE
             pa.STATE !=3
         GROUP BY
             p.center,
             p.id,
             p.status,
             PARAMS.currentdate,
             DEBTORS.center,
             DEBTORS.id
         HAVING
             SUM(
                 CASE
                     WHEN DEBTORS.DUE_DATE + PARAMS.DAYS + 1 <= PARAMS.CURRENTDATE
                     THEN DEBTORS.OpenedAmount
                     ELSE 0
                 END) < 0
             --
         ORDER BY
             MIN(DEBTORS.DUE_DATE) DESC ) s
 WHERE
     NewerDebtAmount = 0
     AND s.PENDING_REQUEST_OR_REP IS NULL
     AND s.OldDebtAmount = s.ar_balance
     AND s.LATEST_NORMAL_REQUEST IS NOT NULL
     AND s.TOTAL_DEBT_AMOUNT = s.OLDDEBTAMOUNT
     and LATEST_NORMAL_REQUEST < trunc(current_timestamp) - 1
