

SELECT
    p.CENTER || 'p' || p.id                                                                                                                                                            pid,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS PERSONTYPE,
    /*    core.HAS_DEBT_ACCOUNT,*/
    core.REQ_AMOUNT cash_collection_req_amount,
    /*    core.STATE, */
    core.TRANS_TIME,
    core.DUE_DATE,
    /*    core.AGENCY_SET,
    core.HAS_CC_STEP,
    core.CURRENT_STEP,
    core.LAST_STEP,
    core.SUBID, */
        CASE
            WHEN core.REQ_AMOUNT + core.payment_reminder = 0 
            THEN 'PAYMENT_REMINDER'
            WHEN core.REQ_AMOUNT + core.converted_debt = 0 
            THEN 'CONVERTED_DEBT'            
            WHEN core.REQ_AMOUNT + core.converted_debt_after = 0 
            THEN 'CONVERTED_DEBT_AFTER'            
            ELSE 'NO MATCH'
        END  settles,
    SUM(art.AMOUNT)  payment_account_balance,
    core.case_amount debt_case_amount,
    SUM(
        CASE
            WHEN art.EMPLOYEECENTER = 100
                AND art.EMPLOYEEID = 1
                AND art.AMOUNT < 0
                AND art.REF_TYPE = 'ACCOUNT_TRANS'
            THEN art.AMOUNT
            ELSE 0
        END)          AS converted_debt,
    MIN(art.DUE_DATE)    earliest_debt,
    MAX(art.DUE_DATE)    latest_debt,
    MIN(prod.NAME)       subscription,
    core.BELOW_MINIMUM_AGE
FROM
    (
        SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID ,
            nvl2(ar_debt.CENTER,1,0) has_debt_account,
            ccr.REQ_AMOUNT,
            SUM(
                CASE
                    WHEN art.TEXT = 'Payment Reminder'
                    THEN art.AMOUNT
                    ELSE 0
                END) AS payment_reminder,
            SUM(
                CASE
                    WHEN art.TEXT != 'Payment Reminder' and art.DUE_DATE < trunc(con.LASTUPDATED,'MM')
                    THEN art.AMOUNT
                    ELSE 0
                END) AS converted_debt,
            SUM(
                CASE
                    WHEN art.TEXT != 'Payment Reminder' and art.DUE_DATE >= trunc(con.LASTUPDATED,'MM')
                    THEN art.AMOUNT
                    ELSE 0
                END) AS converted_debt_after,                
            ccr.STATE,
            cc.BELOW_MINIMUM_AGE,
            MIN(exerpro.longToDate(art.TRANS_TIME))                                                                                                                                         trans_time,
            MIN(art.DUE_DATE)                                                                                                                                                               due_date,
            nvl2(cc.CASHCOLLECTIONSERVICE,1,0)                                                                                                                                              AGENCY_SET,
            EXTRACTVALUE(xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(cc.SETTINGS, 4000,1), 'UTF8')) , '//cashCollectionSettings/cashCollectionStep/cashCollection/@cashCollectionService') has_cc_step,
            DECODE(cc.CURRENTSTEP_TYPE,4,'DEBT_COLLECTION','OTHER')                                                                                                                         current_step,
            nvl2(cc.NEXTSTEP_TYPE,0,1)                                                                                                                                                      last_step,
            ar.CENTER,
            ar.ID,
            ccr.SUBID,
            cc.AMOUNT  case_amount,
            ccr.CENTER ccr_center,
            ccr.ID     ccr_id,
            ccr.SUBID  ccr_subid
        FROM
            CASHCOLLECTIONCASES cc
        left join CONVERTER_ENTITY_STATE con on con.NEWENTITYCENTER = cc.PERSONCENTER and con.NEWENTITYID = cc.PERSONID and con.WRITERNAME = 'ClubLeadPersonWriter'
        JOIN
            CASHCOLLECTION_REQUESTS ccr
        ON
            ccr.CENTER = cc.CENTER
            AND ccr.ID = cc.ID
            AND ccr.STATE < 1
            AND ccr.PAYMENT_REQUEST_CENTER IS NULL
            AND ccr.REQ_AMOUNT > 0
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = cc.PERSONCENTER
            AND ar.CUSTOMERID = cc.PERSONID
            AND ar.AR_TYPE = 4
        LEFT JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
            AND ((
                    art.EMPLOYEECENTER = 100
                    AND art.EMPLOYEEID = 1
                    AND art.REF_TYPE = 'ACCOUNT_TRANS'
                    AND art.AMOUNT < 0
                    AND art.PAYREQ_SPEC_CENTER IS NULL)
                OR (
                    art.TEXT = 'Payment Reminder'
                    AND art.COLLECTED = 1
                    AND art.PAYREQ_SPEC_CENTER IS NULL
                    AND art.AMOUNT = -30) )
            ---AND art.AMOUNT + ccr.REQ_AMOUNT = 0
        LEFT JOIN
            ACCOUNT_RECEIVABLES ar_debt
        ON
            ar_debt.CUSTOMERCENTER = ar.CUSTOMERCENTER
            AND ar_debt.CUSTOMERID = ar.CUSTOMERID
            AND ar_debt.AR_TYPE = 5
        WHERE
            cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
            AND cc.SUCCESSFULL = 0
        --            AND cc.PERSONCENTER = 34
            --and cc.PERSONID = 6320
        GROUP BY
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID ,
            nvl2(ar_debt.CENTER,1,0) ,
            ccr.REQ_AMOUNT,
            ccr.STATE,
            cc.BELOW_MINIMUM_AGE,
            nvl2(cc.CASHCOLLECTIONSERVICE,1,0) ,
            EXTRACTVALUE(xmltype(UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(cc.SETTINGS, 4000,1), 'UTF8')) , '//cashCollectionSettings/cashCollectionStep/cashCollection/@cashCollectionService') ,
            DECODE(cc.CURRENTSTEP_TYPE,4,'DEBT_COLLECTION','OTHER') ,
            nvl2(cc.NEXTSTEP_TYPE,0,1) ,
            ar.CENTER,
            ar.ID,
            ccr.SUBID,
            cc.AMOUNT ,
            ccr.CENTER ,
            ccr.ID ,
            ccr.SUBID
        ORDER BY
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID) core
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = core.customercenter
    AND s.OWNER_ID = core.customerid
    AND s.STATE IN (2,4,8)
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
ON
    p.CENTER = core.customercenter
    AND p.id = core.customerid
LEFT JOIN
    AR_TRANS art
ON
    art.CENTER = core.center
    AND art.id = core.id
GROUP BY
    p.CENTER,
    p.id,
    p.STATUS,
    p.PERSONTYPE,
    core.HAS_DEBT_ACCOUNT,
    core.REQ_AMOUNT,
    core.STATE,
    core.BELOW_MINIMUM_AGE,
    core.TRANS_TIME,
    core.DUE_DATE,
    core.AGENCY_SET,
    core.case_amount,
    core.HAS_CC_STEP,
    core.CURRENT_STEP,
    core.LAST_STEP,
    core.SUBID,
        CASE
            WHEN core.REQ_AMOUNT + core.payment_reminder = 0 
            THEN 'PAYMENT_REMINDER'
            WHEN core.REQ_AMOUNT + core.converted_debt = 0 
            THEN 'CONVERTED_DEBT'            
            WHEN core.REQ_AMOUNT + core.converted_debt_after = 0 
            THEN 'CONVERTED_DEBT_AFTER'            
            ELSE 'NO MATCH'
        END     
ORDER BY
    p.CENTER,
    p.ID