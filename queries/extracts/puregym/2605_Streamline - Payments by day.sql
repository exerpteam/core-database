 SELECT
     TRUNC("DATETIME",'DD') AS "DATE",
     --account,
     SUM(PAYMENT)     AS PAYMENT,
     SUM(REFUND)      AS REFUND,
         SUM(PAYMENT)+SUM(REFUND) as TOTAL,
     COUNT(PAYMENTNB) AS "PAYMENT COUNT",
     COUNT(REFUNDNB)  AS "REFUND COUNT"
 FROM
     (
         SELECT
             longtodateTZ(act.ENTRY_TIME, 'Europe/London') AS "DATETIME",
             acc.name                                      AS account,
             CASE
                 WHEN (art.amount>0)
                 THEN art.amount
                 ELSE 0
             END AS PAYMENT,
             CASE
                 WHEN (art.amount<0)
                 THEN art.amount
                 ELSE 0
             END AS REFUND ,
             CASE
                 WHEN (art.amount>0)
                 THEN ROW_NUMBER() OVER()
                 ELSE NULL
             END AS PAYMENTNB,
             CASE
                 WHEN (art.amount<0)
                 THEN ROW_NUMBER() OVER()
                 ELSE NULL
             END                                     AS REFUNDNB ,
             ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS PersonId,
             p.fullname                              AS Name
         FROM
             ACCOUNTS acc
         JOIN
             ACCOUNT_TRANS act
         ON
             (
                 act.DEBIT_ACCOUNTCENTER = acc.center
             AND act.DEBIT_ACCOUNTID = acc.id )
         OR  (
                 act.CREDIT_ACCOUNTCENTER = acc.center
             AND act.CREDIT_ACCOUNTID = acc.id )
         JOIN
             AR_TRANS art
         ON
             art.REF_TYPE = 'ACCOUNT_TRANS'
         AND art.REF_CENTER = act.center
         AND art.REF_ID = act.id
         AND art.REF_SUBID = act.subid
         JOIN
             ACCOUNT_RECEIVABLES AR
         ON
             AR.CENTER = art.CENTER
         AND AR.ID = ART.ID
         JOIN
             PERSONS P
         ON
             P.CENTER = AR.CUSTOMERCENTER
         AND P.ID = AR.CUSTOMERID
         WHERE
             act.AMOUNT <> 0
         AND acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT',
                              'BANK_ACCOUNT_WEB','PAYTEL')
         AND act.ENTRY_TIME >= :fromDate
         AND act.ENTRY_TIME < :toDate + 24*3600*1000 ) t
 GROUP BY
     TRUNC("DATETIME",'DD')
     --account
 ORDER BY
     "DATE"
