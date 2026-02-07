SELECT
       subq.personcenter||'p'||subq.personid AS MEMBER_ID,
       subq.CASE_START_DATETIME, 
       subq.CASE_CLOSED_DATETIME, 
       subq.BALANCE_AT_CASE_START, 
       subq.PA_STATE, Decode(cc2.MISSINGPAYMENT,1,'Yes','No') AS Missing_payment_debt_account, 
       pea.TXTVALUE as Email
FROM
(
SELECT
    ar.CUSTOMERCENTER as personcenter,
    ar.customerid as personid,
    longtodateC(ccc.START_DATETIME,ccc.PERSONCENTER)                                                                                                                                                                                                        AS CASE_START_DATETIME,
    longtodateC(ccc.CLOSED_DATETIME,ccc.PERSONCENTER)                                                                                                                                                                                                        AS CASE_CLOSED_DATETIME,
    NVL(SUM(art.AMOUNT),0)                                                                                                                                                                                                        AS BALANCE_AT_CASE_START,
    DECODE(pa.STATE , 1,'CREATED', 2,'SENT', 3,'FAILED', 4,'AGREEMENT CONFIRMED', 5,'ENDED BY DEBITOR''S BANK', 6,'ENDED BY THE CLEARING HOUSE', 7,'ENDED BY DEBITOR', 8,'SHAL BE CANCELLED', 9,'END REQUEST SENT', 10,'AGREEMENT ENDED BY CREDITOR', 11,'NO AGREEMENT WITH DEBITOR', 12,'DEPRICATED', 13,'NOT NEEDED',14,'INCOMPLETE',15,'TRANSFERRED','UNKNOWN') AS PA_STATE
FROM
    VA.CASHCOLLECTIONCASES ccc
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = ccc.PERSONCENTER
    AND ar.CUSTOMERID = ccc.PERSONID
    AND ar.AR_TYPE = 4
LEFT JOIN
    VA.AR_TRANS art
ON
    art.center = ar.center
    AND art.id = ar.id
    AND art.ENTRY_TIME <= ccc.START_DATETIME
LEFT JOIN
    VA.PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
    AND pac.id = ar.id
LEFT JOIN
    VA.PAYMENT_AGREEMENTS pa
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
   