SELECT DISTINCT 
pa.notify_payment,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID                                                                                                               pid,
    FIRST_VALUE(longToDate(pr.ENTRY_TIME)) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY pr.ENTRY_TIME ASC) LATEST_REQUEST_CREATED,
    FIRST_VALUE(pr.REJECTED_REASON_CODE) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY pr.ENTRY_TIME ASC)           LATEST_REJECTION_CODE,
    FIRST_VALUE(pr.XFR_INFO) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY pr.ENTRY_TIME ASC)                       LATEST_REJECTION_REASON,
    FIRST_VALUE(prs.REF) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY pr.ENTRY_TIME ASC)                           LATEST_PAYMENT_REQ_REF,

    DECODE(pa.STATE ,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete')
                                                                                                                                                                                                       PA_STATE_ID,
pa.EXPIRATION_DATE,
    pa.CLEARINGHOUSE_REF                                                                                                                                                                                                        AGREEMENT_REFERENCE,
    FIRST_VALUE(acl.TEXT) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE ASC)                                                                                                                                                                                                        EARLIEST_AGREEMENT_LOG_TEXT,
    FIRST_VALUE(longToDate(acl.ENTRY_TIME)) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE ASC)                                                                                                                                                                              EARLIEST_LOG_ENTRY_TIME,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') PA_STATE,
    FIRST_VALUE(acl.TEXT) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE DESC)                                                                                                                                                                                                       LATEST_AGREEMENT_LOG_TEXT,
    FIRST_VALUE(longToDate(acl.ENTRY_TIME)) OVER (PARTITION BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE DESC)                                                                                                                                                                             LATEST_LOG_ENTRY_TIME,
    longToDate(pa.CREATION_TIME)                                                                                                                                                                                                        agreement_created,
    emp.center || 'emp' || emp.id                                                                                                                                                                                                        created_by_emp,
    empp.center || 'p' || empp.id                                                                                                                                                                                                        created_by_p,
    empp.Fullname                                                                                                                                                                                                        created_by_name
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.ACTIVE_AGR_CENTER = pa.CENTER
    AND pac.ACTIVE_AGR_ID = pa.ID
    AND pac.ACTIVE_AGR_SUBID = pa.SUBID
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pa.CENTER
    AND prs.ID =pa.id
    AND prs.SUBID = pa.SUBID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pac.CENTER
    AND ar.ID = pac.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.customercenter
    AND p.id = ar.customerid
    AND p.STATUS IN (0,1,2,3,6,9)
LEFT JOIN
    AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = pa.CENTER
    AND acl.AGREEMENT_ID = pa.ID
    AND acl.AGREEMENT_SUBID = pa.SUBID
LEFT JOIN
    JOURNALENTRIES je
ON
    je.REF_CENTER = pa.CENTER
    AND je.REF_ID = pa.ID
    AND je.REF_SUBID = pa.SUBID
    AND je.PERSON_CENTER = ar.CUSTOMERCENTER
    AND je.PERSON_ID = ar.CUSTOMERID
    AND je.JETYPE = 11
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = je.CREATORCENTER
    AND emp.ID = je.CREATORID
LEFT JOIN
    PERSONS empp
ON
    empp.CENTER = emp.PERSONCENTER
    AND empp.id = emp.PERSONID
WHERE
    pa.CLEARINGHOUSE = 803
/*
pa.CLEARINGHOUSE in 
(1201,
1401,
1405,
1410,
1413,
1421,
1426,
1406,
1409,
1404,
1407,
1408,
1411,
1412,
1415,
1416,
1417,
1418,
1423,
1422,
1202,
1402,
1403,
1414,
1419,
1420,
1424,
1425,
1427,
1428)
*/
    
    