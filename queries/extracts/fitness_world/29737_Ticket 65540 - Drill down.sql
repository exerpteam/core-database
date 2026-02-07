-- This is the version from 2026-02-05
--  
SELECT
    ar.CUSTOMERCENTER center_payer,
    ar.CUSTOMERID id_payer,    
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
            DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            s.CENTER || 'ss' || s.ID                                                                                                                                    ssid,
            prod.NAME                                                                                                                                                   sub_name
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
        LEFT JOIN
            SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
            AND s.STATE IN (2,4,7)
        LEFT JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
            ev.EVENT_CONFIGURATION_ID = 2831
        GROUP BY
            p.CENTER,
            p.ID,
            p.PERSONTYPE,
            s.CENTER,
            s.ID,
            prod.NAME ) q1
LEFT JOIN
    FW.RELATIVES rel
ON
    rel.RTYPE = 12
    AND rel.RELATIVECENTER = q1.center
    AND rel.RELATIVEID = q1.id
    AND rel.STATUS = 1
left JOIN
    FW.ACCOUNT_RECEIVABLES ar
ON
    (
        rel.CENTER IS NULL
        AND ar.CUSTOMERCENTER = q1.CENTER
        AND ar.CUSTOMERID = q1.ID
        AND ar.AR_TYPE = 4 )
    OR (
        rel.CENTER IS NOT NULL
        AND ar.CUSTOMERCENTER = rel.CENTER
        AND ar.CUSTOMERID = rel.ID
        AND ar.AR_TYPE = 4 )
left join   AR_TRANS art on art.CENTER = ar.CENTER and art.ID = ar.ID and art.TEXT = 'Træningsmakker - Manglende checkin'
