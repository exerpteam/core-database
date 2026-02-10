-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    q2.CENTER_PAYER,
    q2.ID_PAYER,
    q2.LOG_CNT,
    q2.CENTER_CUSTOMER,
    q2.ID_CUSTOMER,
    q2.PERSONTYPE,
    q2.SSID,
    q2.SUB_NAME,
    q2.TOT_AMOUNT INVOICED,
    (
        SELECT
            SUM(cnl.TOTAL_AMOUNT)
        FROM
            AR_TRANS art
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
        JOIN
            CREDIT_NOTE_LINES cnl
        ON
            cnl.CENTER = art.REF_CENTER
            AND cnl.ID = art.REF_ID
            AND art.REF_TYPE = 'CREDIT_NOTE'
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = cnl.PRODUCTCENTER
            AND cnl.PRODUCTID = prod.ID
            AND prod.GLOBALID in ('NON_LOCAL_CHECKIN_FEE','BUDDY_NO_CHECKIN')
        WHERE
            ar.CUSTOMERCENTER = q2.CENTER_PAYER
            AND ar.CUSTOMERID = q2.ID_PAYER
            AND ar.AR_TYPE = 4 
            and art.TRANS_TIME > $$cretedfrom$$
            ) CREDITED
FROM
    (
        SELECT
            AR_CENTER,
            AR_ID,
            CENTER_PAYER,
            ID_PAYER,
            LOG_CNT,
            CENTER CENTER_CUSTOMER,
            ID     ID_CUSTOMER,
            PERSONTYPE,
            SSID,
            SUB_NAME,
            SUM(AMOUNT) TOT_AMOUNT
        FROM
            (
                SELECT
                    ar.CENTER         AR_CENTER,
                    ar.ID             AR_ID,
                    ar.CUSTOMERCENTER center_payer,
                    ar.CUSTOMERID     id_payer,
                    q1.*,
                    art.TEXT,
                    art.AMOUNT
                FROM
                    (
                        SELECT
                            --    exerpro.longToDate(ci.CHECKIN_TIME)                                                                                                                         CHECKIN_TIME,
                            --    ev.ID                                                                                                                                                       EVENT_LOG_ID,
                            COUNT(p.CENTER) log_cnt,
                            p.CENTER,
                            p.ID,
                            DECODE ( sclP.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
                            s.CENTER || 'ss' || s.ID                                                                                                                                    ssid,
                            prod.NAME                                                                                                                                                   sub_name,
                            sclOP.CENTER                                                                                                                                                CENTER_OP,
                            sclOP.ID                                                                                                                                                    ID_OP
                        FROM
                            EVENT_LOG ev
                        JOIN
                            CHECKINS ci
                        ON
                            ci.ID = ev.REFERENCE_ID
                        JOIN
                            PERSONS p
                        ON
                            p.CENTER = ci.PERSON_CENTER
                            AND p.ID = ci.PERSON_ID
                        JOIN
                            SUBSCRIPTIONS s
                        ON
                            s.OWNER_CENTER = p.CENTER
                            AND s.OWNER_ID = p.ID
                        JOIN
                            PRODUCTS prod
                        ON
                            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
                        JOIN
                            STATE_CHANGE_LOG sclS
                        ON
                            sclS.CENTER = s.CENTER
                            AND sclS.ID = s.ID
                            AND sclS.ENTRY_TYPE = 2
                            AND sclS.ENTRY_START_TIME <= ci.CHECKIN_TIME
                            AND (
                                sclS.ENTRY_END_TIME IS NULL
                                OR sclS.ENTRY_END_TIME > ci.CHECKIN_TIME)
                            AND sclS.STATEID IN (2)
                        JOIN
                            STATE_CHANGE_LOG sclP
                        ON
                            sclP.CENTER = ci.PERSON_CENTER
                            AND sclP.ID = ci.PERSON_ID
                            AND sclP.ENTRY_TYPE = 3
                            AND sclP.ENTRY_START_TIME <= ci.CHECKIN_TIME
                            AND (
                                sclP.ENTRY_END_TIME IS NULL
                                OR sclP.ENTRY_END_TIME > ci.CHECKIN_TIME)
                        LEFT JOIN
                            RELATIVES rel
                        ON
                            rel.RELATIVECENTER = ci.PERSON_CENTER
                            AND rel.RELATIVEID = ci.PERSON_ID
                            AND rel.RTYPE = 12
                        LEFT JOIN
                            STATE_CHANGE_LOG sclOP
                        ON
                            sclOP.CENTER = rel.CENTER
                            AND sclOP.ID = rel.ID
                            AND sclOP.ENTRY_TYPE = 4
                            AND sclOP.ENTRY_START_TIME <= ci.CHECKIN_TIME
                            AND (
                                sclOP.ENTRY_END_TIME IS NULL
                                OR sclOP.ENTRY_END_TIME > ci.CHECKIN_TIME)
                            AND rel.STATUS = 1
                        WHERE
                            ev.EVENT_CONFIGURATION_ID = 2831
                            and ci.CHECKIN_TIME > $$cretedfrom$$
                            --and ci.PERSON_CENTER = 102 and ci.PERSON_ID = 1561
                        GROUP BY
                            p.CENTER,
                            sclP.STATEID,
                            p.ID,
                            p.PERSONTYPE,
                            s.CENTER,
                            s.ID,
                            prod.NAME,
                            sclOP.CENTER ,
                            sclOP.ID ) q1
                JOIN
                    FW.ACCOUNT_RECEIVABLES ar
                ON
                    (
                        q1.center_op IS NOT NULL
                        AND ar.CUSTOMERCENTER = q1.center_op
                        AND ar.CUSTOMERID = q1.id_op
                        AND ar.AR_TYPE = 4 )
                    OR (
                        q1.center_op IS NULL
                        AND ar.CUSTOMERCENTER = q1.CENTER
                        AND ar.CUSTOMERID = q1.ID
                        AND ar.AR_TYPE = 4 )
                JOIN
                    AR_TRANS art
                ON
                    art.CENTER = ar.CENTER
                    AND art.ID = ar.ID
                    and art.TRANS_TIME > $$cretedfrom$$
                JOIN
                    INVOICELINES invl
                ON
                    invl.CENTER = art.REF_CENTER
                    AND invl.ID = art.REF_ID
                    AND art.REF_TYPE = 'INVOICE'
                JOIN
                    PRODUCTS prod
                ON
                    prod.CENTER = invl.PRODUCTCENTER
                    AND prod.id = invl.PRODUCTID
                    AND prod.GLOBALID = 'NON_LOCAL_CHECKIN_FEE' )
        GROUP BY
            AR_CENTER,
            AR_ID,
            CENTER_PAYER,
            ID_PAYER,
            LOG_CNT,
            AR_CENTER,
            AR_ID,
            CENTER ,
            ID ,
            PERSONTYPE,
            SSID,
            SUB_NAME)q2