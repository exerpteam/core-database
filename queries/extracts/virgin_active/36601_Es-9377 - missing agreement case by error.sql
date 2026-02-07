 SELECT
        subq.personcenter||'p'||subq.personid AS MEMBER_ID,
        subq.CASE_START_DATETIME,
        subq.CASE_CLOSED_DATETIME,
        subq.BALANCE_AT_CASE_START,
        subq.PA_STATE, Case cc2.MISSINGPAYMENT When 1 Then 'Yes' Else 'No' End AS Missing_payment_debt_account,
        pea.TXTVALUE as Email,
        CASE  DELIVERYCODE  WHEN 0 THEN  'UNDELIVERED'  WHEN 1 THEN  'STAFF'  WHEN 2 THEN  'EMAIL'  WHEN 3 THEN  'EXPIRED' WHEN 4 THEN  'KIOSK' WHEN 5 THEN  'WEB' WHEN 6 THEN  'SMS' WHEN 7 THEN  'CANCELED' WHEN 8 THEN  'LETTER' WHEN 9 THEN  'FAILED' WHEN 10 THEN  'UNCHARGABLE' ELSE '' END AS DELIVERY_METHOD
 FROM
 (
 SELECT
     ar.CUSTOMERCENTER as personcenter,
     ar.customerid as personid,
     longtodateC(ccc.START_DATETIME,ccc.PERSONCENTER)                                                                                                                                                                                                        AS CASE_START_DATETIME,
     longtodateC(ccc.CLOSED_DATETIME,ccc.PERSONCENTER)                                                                                                                                                                                                        AS CASE_CLOSED_DATETIME,
     COALESCE(SUM(art.AMOUNT),0)                                                                                                                                                                                                        AS BALANCE_AT_CASE_START,
     CASE pa.STATE  WHEN 1 THEN 'CREATED'  WHEN 2 THEN 'SENT'  WHEN 3 THEN 'FAILED'  WHEN 4 THEN 'AGREEMENT CONFIRMED'  WHEN 5 THEN 'ENDED BY DEBITOR''S BANK'  WHEN 6 THEN 'ENDED BY THE CLEARING HOUSE'  WHEN 7 THEN 'ENDED BY DEBITOR'  WHEN 8 THEN 'SHAL BE CANCELLED'  WHEN 9 THEN 'END REQUEST SENT'  WHEN 10 THEN 'AGREEMENT ENDED BY CREDITOR'  WHEN 11 THEN 'NO AGREEMENT WITH DEBITOR'  WHEN 12 THEN 'DEPRICATED'  WHEN 13 THEN 'NOT NEEDED' WHEN 14 THEN 'INCOMPLETE' WHEN 15 THEN 'TRANSFERRED' ELSE 'UNKNOWN' END AS PA_STATE
 FROM
     CASHCOLLECTIONCASES ccc
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = ccc.PERSONCENTER
     AND ar.CUSTOMERID = ccc.PERSONID
     AND ar.AR_TYPE = 4
 LEFT JOIN
     AR_TRANS art
 ON
     art.center = ar.center
     AND art.id = ar.id
     AND art.ENTRY_TIME <= ccc.START_DATETIME
 LEFT JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.center = ar.center
     AND pac.id = ar.id
 LEFT JOIN
     PAYMENT_AGREEMENTS pa
 ON
     pa.center = pac.ACTIVE_AGR_CENTER
     AND pa.id = pac.ACTIVE_AGR_ID
     AND pa.SUBID = pac.ACTIVE_AGR_SUBID
 WHERE
     ccc.START_DATETIME BETWEEN 1527033208083 -1000*60*30 AND 1527033208083 +1000*60*30
     AND ccc.MISSINGPAYMENT = 0
     AND ccc.CLOSED = 1
     AND ar.CENTER in (:Scope)
 GROUP BY
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID,
     longtodateC(ccc.START_DATETIME,ccc.PERSONCENTER),
     longtodateC(ccc.CLOSED_DATETIME,ccc.PERSONCENTER),
     ccc.CLOSED_DATETIME,
     pa.STATE
 ) subq
 LEFT JOIN
     PERSON_EXT_ATTRS pea
 ON
    pea.PERSONCENTER = subq.PERSONCENTER
    AND pea.PERSONID = subq.PERSONID
    AND pea.NAME = '_eClub_Email'
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar_debt
 ON
     ar_debt.CUSTOMERCENTER = subq.PERSONCENTER
     AND ar_debt.CUSTOMERID = subq.PERSONID
     AND ar_debt.AR_TYPE = 5
 LEFT JOIN
     CASHCOLLECTIONCASES cc2
 ON
     ar_debt.CUSTOMERCENTER = cc2.PERSONCENTER
     AND ar_debt.CUSTOMERID = cc2.PERSONID
     AND ar_debt.ID = cc2.AR_ID
     AND ar_debt.CENTER = cc2.AR_CENTER
     AND cc2.MISSINGPAYMENT = 1
     AND cc2.CLOSED = 0
 LEFT JOIN
     MESSAGES m
 ON
     m.center = subq.PERSONCENTER
     AND m.SUBJECT in ('Direct Debit Cancellation', 'Virgin Active Italia - Rettifica Dati Pagamento')
     AND m.ID = subq.PERSONID
     AND m.SENTTIME > 1526990400000
     AND m.SENTTIME < 1527105600000
