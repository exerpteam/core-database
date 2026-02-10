-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cc.PERSONCENTER || 'p' || cc.PERSONID pid,
    p.FULLNAME,
    'ACTIVE'                       AS STATUS,
    DECODE(cc.HOLD,0,'NO',1,'YES')    HOLD,
    cc.STARTDATE,
    cc.AMOUNT                                                                                                                                                                                                        DEBT,
    'Overdue debt'                                                                                                                                                                                                        procedure_type ,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') state,
    chc.CREDITOR_ID                                                                                                                                                                                                        clearing_house_creditor
FROM
    CASHCOLLECTIONCASES cc
JOIN
    PERSONS p
ON
    p.CENTER = cc.PERSONCENTER
    AND p.ID = cc.PERSONID
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = cc.PERSONCENTER
    AND ar.CUSTOMERID = cc.PERSONID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pac.ACTIVE_AGR_SUBID = pa.SUBID
LEFT JOIN
    CLEARINGHOUSE_CREDITORS chc
ON
    chc.CLEARINGHOUSE = pa.CLEARINGHOUSE
    AND chc.CREDITOR_ID = pa.CREDITOR_ID
JOIN
    CENTERS c
ON
    c.id = cc.PERSONCENTER
    AND c.COUNTRY = 'IT'
WHERE
    cc.MISSINGPAYMENT = 1
    AND cc.CLOSED = 0
        AND cc.STARTDATE >= TRUNC(SYSDATE - 1)
        AND cc.STARTDATE < TRUNC(SYSDATE)