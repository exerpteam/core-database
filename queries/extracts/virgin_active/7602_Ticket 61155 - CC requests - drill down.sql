SELECT
    i1.*,
    s.CENTER || 'ss' || s.ID            ssid,
    longToDate(s.CREATION_TIME) sub_created,
            DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
            DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') as SUB_STATE,

    s.START_DATE,
    s.END_DATE,
    s.BINDING_END_DATE,
    prod.NAME            sub_name,
    nvl2(rel.CENTER,1,0) is_other_payer,
            p.FIRSTNAME,
            p.LASTNAME
FROM
    (
        SELECT
            cc.PERSONCENTER,
            cc.PERSONID ,
            nvl2(arDebt.center,1,0) has_debt_account,
            MAX(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NULL
                    THEN 1
                    ELSE 0
                END) AS "UNSENT MISSING REF",
            SUM(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NULL
                    THEN ccr.REQ_AMOUNT
                    ELSE 0
                END) AS "UNSENT MISSING REF SUM",
            MIN(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NULL
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "UNSENT MISSING REF OLDEST",
            MAX(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NULL
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "UNSENT MISSING REF NEWEST",
            MAX(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NOT NULL
                    THEN 1
                    ELSE 0
                END) AS "UNSENT HAS BEEN HALTED",
            SUM(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NOT NULL
                    THEN ccr.REQ_AMOUNT
                    ELSE 0
                END) AS "UNSENT HAS BEEN HALTED SUM",
            MIN(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NOT NULL
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "UNSENT HAS BEEN HALTED OLDEST",
            MAX(
                CASE
                    WHEN ccr.STATE IN (-1,0)
                        AND ccr.PAYMENT_REQUEST_CENTER IS NOT NULL
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "UNSENT HAS BEEN HALTED NEWEST",
            MAX(
                CASE
                    WHEN ccr.STATE IN (1)
                    THEN 1
                    ELSE 0
                END) AS "DEBT AT ARC",
            SUM(
                CASE
                    WHEN ccr.STATE IN (1)
                    THEN ccr.REQ_AMOUNT
                    ELSE 0
                END) AS "DEBT AT ARC SUM" ,
            MIN(
                CASE
                    WHEN ccr.STATE IN (1)
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "DEBT AT ARC OLDEST" ,
            MAX(
                CASE
                    WHEN ccr.STATE IN (1)
                    THEN ccr.REQ_DATE
                    ELSE NULL
                END) AS "DEBT AT ARC NEWEST"
        FROM
            CASHCOLLECTION_REQUESTS ccr
            /* Only include cases where we have an open cash collection case */
        JOIN
            CASHCOLLECTIONCASES cc
        ON
            cc.CENTER = ccr.CENTER
            AND cc.ID = ccr.ID
            AND cc.MISSINGPAYMENT = 1
            AND cc.CLOSED = 0
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = cc.PERSONCENTER
            AND ar.CUSTOMERID = cc.PERSONID
            AND ar.AR_TYPE = 4
        LEFT JOIN
            ACCOUNT_RECEIVABLES arDebt
        ON
            arDebt.CUSTOMERCENTER = cc.PERSONCENTER
            AND arDebt.CUSTOMERID = cc.PERSONID
            AND arDebt.AR_TYPE = 5
        WHERE
            /* There should be at least one bad one in the cash collection case */
            EXISTS
            (
                SELECT
                    1
                FROM
                    CASHCOLLECTION_REQUESTS ccr2
                WHERE
                    ccr2.CENTER = ccr.CENTER
                    AND ccr2.ID = ccr.ID
                    AND ccr2.STATE IN (-1,0)
                    AND ccr2.PAYMENT_REQUEST_CENTER IS NULL
                    AND ccr2.REQ_AMOUNT > 0 )
            AND ccr.REQ_AMOUNT > 0
        GROUP BY
            cc.PERSONCENTER,
            cc.PERSONID,
            arDebt.center ) i1
JOIN
    PERSONS p
ON
    p.CENTER = i1.PERSONCENTER
    AND p.ID = i1.PERSONID
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
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 12
    AND rel.STATUS = 1