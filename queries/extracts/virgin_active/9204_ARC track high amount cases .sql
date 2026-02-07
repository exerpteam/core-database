SELECT
    CLUB,
    CLUB_ID,
    PERSON_ID,
    EXTERNAL_ID,
    legacy_id,
    PERSON_NAME,
    ADDRESS1,
    ADDRESS2,
    ADDRESS3,
    ZIPCODE,
    CITY,
    COUNTRY,
    LATEST_DEBT_COMMENT,
    ACCOUNT_TYPE,
    OLDEST_DEBT_REQUEST,
    subscription,
    SUBSCRIPTION_PRICE,
    BINDING_END_DATE,
    END_DATE ,
    latest_sent_request,
    is_other_payer,
    MAX(positive_transaction) latest_payment,
    MIN(due_date)             entry_earliest_debt,
    SUM(AMOUNT)               balance,
    SUM(UNSETTLED)            overdue
FROM
    (
        SELECT
            c.NAME                  Club,
            c.ID                    club_id,
            p.CENTER || 'p' || p.ID Person_ID,
            p.EXTERNAL_ID,
            extId.TXTVALUE LEGACY_ID,
            p.FULLNAME     Person_Name,
            p.ADDRESS1,
            p.ADDRESS2,
            p.ADDRESS3,
            p.ZIPCODE,
            p.CITY,
            p.COUNTRY,
            (
                SELECT
                    MAX(longToDate(m.SENTTIME))
                FROM
                    MESSAGES m
                WHERE
                    m.TEMPLATETYPE IN (13,14,55,67)
                    AND m.CENTER = p.CENTER
                    AND m.id = p.id)                         latest_debt_comment,
            DECODE(ar.AR_TYPE,1,'Cash',4,'Payment',5,'Debt') ACCOUNT_TYPE,
            art.AMOUNT,
            art.UNSETTLED_AMOUNT,
            CASE
                WHEN art.UNSETTLED_AMOUNT != 0
                    AND art.DUE_DATE < SYSDATE
                THEN art.UNSETTLED_AMOUNT
                ELSE NULL
            END AS unsettled,
            CASE
                WHEN art.UNSETTLED_AMOUNT != 0
                    AND art.DUE_DATE < SYSDATE
                THEN longToDate(art.ENTRY_TIME)
                ELSE NULL
            END AS due_date,
            CASE
                WHEN art.REF_TYPE = 'ACCOUNT_TRANS'
                    AND art.AMOUNT > 0 and 
    (
        art.TEXT NOT LIKE 'Transfer to cash collection account%'
        AND art.TEXT NOT LIKE 'Payment: Converted subscription invoice%'
        AND art.TEXT NOT LIKE 'Transfer to cash collection account%' 
        AND art.TEXT NOT LIKE 'Transfer between accounts%' 

)
                THEN longToDate(art.ENTRY_TIME)
                ELSE NULL
            END            AS positive_transaction,
            i1.oldest_debt    oldest_debt_request,
            i1.latest_sent_request,
            prod.NAME subscription,
            s.SUBSCRIPTION_PRICE,
            s.BINDING_END_DATE,
            s.END_DATE,
            nvl2(rel.CENTER,1,0) is_other_payer
        FROM
            (
                SELECT
                    cc.PERSONCENTER    center,
                    cc.PERSONID        id,
                    MIN(ccr3.REQ_DATE) oldest_debt,
                    MAX(ccr.REQ_DATE)  latest_sent_request
                FROM
                    CASHCOLLECTION_REQUESTS ccr
                JOIN
                    CASHCOLLECTIONCASES cc
                ON
                    cc.CENTER = ccr.CENTER
                    AND cc.ID = ccr.ID
                JOIN
                    CASHCOLLECTION_REQUESTS ccr3
                ON
                    ccr3.CENTER = ccr.CENTER
                    AND ccr3.ID = ccr.ID
                WHERE
                    (
                        ccr.STATE = 1
                        AND ccr.REQ_DELIVERY IS NOT NULL)
                    AND cc.PERSONCENTER IN ($$scope$$)
                    AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            CASHCOLLECTION_REQUESTS ccr2
                        WHERE
                            ccr2.CENTER = ccr.CENTER
                            AND ccr2.ID = ccr.ID
                            AND ccr2.SUBID < ccr.SUBID
                            AND ccr2.STATE IN (-1,1,6)
                            AND ccr2.REQ_DELIVERY IS NULL )
                GROUP BY
                    cc.PERSONCENTER,
                    cc.PERSONID ) i1
        JOIN
            PERSONS p
        ON
            p.CENTER = i1.center
            AND p.ID = i1.id
        LEFT JOIN
            RELATIVES rel
        ON
            rel.RTYPE = 12
            AND rel.STATUS = 1
            AND rel.CENTER = p.CENTER
            AND rel.ID = p.ID
        JOIN
            CENTERS c
        ON
            c.ID = p.CENTER
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,8)
        LEFT JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
        LEFT JOIN
            AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.ID = ar.ID
        LEFT JOIN
            PERSON_EXT_ATTRS extId
        ON
            extId.PERSONCENTER = p.CENTER
            AND extId.PERSONID = p.ID
            AND extId.NAME = '_eClub_OldSystemPersonId' )
GROUP BY
    CLUB,
    CLUB_ID,
    PERSON_ID,
    EXTERNAL_ID,
    PERSON_NAME,
    ADDRESS1,
    ADDRESS2,
    ADDRESS3,
    ZIPCODE,
    CITY,
    COUNTRY,
    LATEST_DEBT_COMMENT,
    ACCOUNT_TYPE,
    OLDEST_DEBT_REQUEST,
    subscription,
    SUBSCRIPTION_PRICE,
    BINDING_END_DATE,
    END_DATE,
    latest_sent_request,
    legacy_id,
    is_other_payer
ORDER BY
    PERSON_ID,
    ACCOUNT_TYPE