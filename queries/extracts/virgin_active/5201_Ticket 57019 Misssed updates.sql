
SELECT
    CASE
        WHEN i1.ARC_CASE = 0
            AND i1.EXPORTED_DEBT = 0
            AND i1.OVER_18 = 1
            AND i1.DEBT_OVER_25 = 1
            AND i1.CREDITOR_ID = 'BACS UK'
            AND i1.SEX NOT IN ('c','C')
        THEN 1
        ELSE 0
    END SHOULD_HAVE_BEEN_UPDATED,
    i1.*
FROM
    (
        SELECT
            cc.PERSONCENTER || 'p' || cc.PERSONID pid,
            MAX(NVL(EXTRACTVALUE(xmltype(
                CASE
                    WHEN LENGTH(cc.SETTINGS) < 2001
                    THEN UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(cc.SETTINGS, 4000,1), 'UTF8')
                    ELSE UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(cc.SETTINGS, 2000,1), 'UTF8') || UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(cc.SETTINGS, 2000,2001), 'UTF8')
                END ), '//cashCollection/@cashCollectionService'),0)) ARC_CASE,
            MAX(
                CASE
                    WHEN art.CENTER IS NULL
                    THEN 0
                    ELSE 1
                END) AS EXPORTED_DEBT,
            MIN(
                CASE
                    WHEN floor(months_between(TRUNC(cc.STARTDATE),p.BIRTHDATE)/12) >= 18
                    THEN 1
                    ELSE 0
                END) AS OVER_18,
            MIN(
                CASE
                    WHEN cc.AMOUNT >= 25
                    THEN 1
                    ELSE 0
                END)                                                                                                                                                                             AS DEBt_OVER_25,
            MIN(DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN')) AS PERSON_STATUS,
            MIN(pa.CREDITOR_ID)                                                                                                                                                                     CREDITOR_ID,
            MIN(p.SEX)                                                                                                                                                                              SEX,
            MAX(nvl2(s.CENTER,1,0))                                                                                                                                                                 BLOCKED_SUB,
            MAX(nvl2(rel.CENTER,1,0)) IS_OTHER_PAYER
        FROM
            CASHCOLLECTIONCASES cc
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
            AND art.EMPLOYEECENTER = 100
            AND art.EMPLOYEEID = 1
            AND art.AMOUNT < 0
        JOIN
            PERSONS p
        ON
            p.CENTER = cc.PERSONCENTER
            AND p.id = cc.PERSONID
        left join RELATIVES rel on rel.CENTER = p.CENTER and rel.ID = p.ID and rel.RTYPE = 12 and rel.STATUS = 1    
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.SUB_STATE = 9
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
            AND pa.SUBID = pac.ACTIVE_AGR_SUBID
        WHERE
            cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
            AND cc.PERSONCENTER in (:scope)
        GROUP BY
            cc.PERSONCENTER,
            cc.PERSONID ) i1
