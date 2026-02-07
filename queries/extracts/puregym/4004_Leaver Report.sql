WITH
    PARAMS AS
    (
        SELECT /*+ materialize */
            $$center$$                                                                                 AS CENTER ,
            datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' )  AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
        FROM
            (
                SELECT
                    $$for_date$$ AS currentdate
                FROM
                    DUAL )
    )
SELECT
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER || 'p' || p.ID AS Pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY   AS pin,
    pem.TXTVALUE AS email,
    ph.TXTVALUE  AS phoneHome,
    pm.TXTVALUE  AS mobile,
    CASE
        WHEN acl.text = 'Direct to OK'
            AND acl.xfr_info = 'Refer to payer'
        THEN 'PureGym cancelled'
        ELSE 'Member Cancelled'
    END                                                                                                                                                                                                        AS "Cancelled by",
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea_creation.txtvalue)                                                                                                                                                                                                        AS MemberSinceDate,
    acl.text                                                                                                                                                                                                        AS "Payment agreement last state",
    NVL(acl.xfr_info,DECODE(acl.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manuel',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed','UNDEFINED')) AS "Payment request last state",
    MAX(longtodatetz(ch.CHECKIN_TIME,'Europe/London')) as "last attendance"
FROM
    (
        -- That are not in incoming balance
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            SUBSCRIPTIONTYPES ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
            AND SU.CENTER = PARAMS.CENTER
            AND EXISTS
            (
                -- In outgoing balance
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.BOOK_START_TIME < PARAMS.STARTTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.STARTTIME )
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN ( 2,
                                        4,8)
                    -- Time safety. We need to exclude subscriptions
                    -- started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will
                    -- not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME )
        MINUS
        -- Outoing balance members
        SELECT DISTINCT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            SUBSCRIPTIONTYPES ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS) 
            AND SU.CENTER = PARAMS.CENTER
            AND EXISTS
            (
                -- In outgoing balance
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL
                WHERE
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.BOOK_START_TIME < PARAMS.ENDTIME
                    AND (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.ENTRY_END_TIME >= PARAMS.HARDCLOSETIME
                        OR SCL.BOOK_END_TIME >= PARAMS.ENDTIME )
                    AND SCL.ENTRY_TYPE = 2
                    AND SCL.STATEID IN ( 2,
                                        4,8)
                    -- Time safety. We need to exclude subscriptions      -- started in the past so they do
                    -- not
                    -- get
                    -- into the incoming balance because they will
                    -- not be in the outgoing balance
                    -- of
                    -- the
                    -- previous day
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME ) ) LEAVERS
JOIN
    PERSONS p
ON
    p.center = leavers.owner_center
    AND p.id = leavers.owner_id
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS pea_creation
ON
    pea_creation.personcenter = p.center
    AND pea_creation.personid = p.id
    AND pea_creation.NAME = 'CREATION_DATE'
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    (
        SELECT
            ar.CUSTOMERCENTER,
            ar.CUSTOMERID,
            acl.TEXT,
            pr.XFR_INFO,
            pr.STATE
        FROM
            PUREGYM.ACCOUNT_RECEIVABLES ar
        JOIN
            PUREGYM.PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.id = ar.ID
        JOIN
            (
                SELECT
                    acl.AGREEMENT_CENTER,
                    acl.AGREEMENT_ID,
                    acl.AGREEMENT_SUBID,
                    MAX(ENTRY_TIME) ENTRY_TIME
                FROM
                    params,
                    PUREGYM.AGREEMENT_CHANGE_LOG acl
                WHERE
                    acl.ENTRY_TIME < params.HARDCLOSETIME
                GROUP BY
                    acl.AGREEMENT_CENTER,
                    acl.AGREEMENT_ID,
                    acl.AGREEMENT_SUBID) max_acl
        ON
            max_acl.AGREEMENT_CENTER = pac.ACTIVE_AGR_CENTER
            AND max_acl.AGREEMENT_ID = pac.ACTIVE_AGR_ID
            AND max_acl.AGREEMENT_SUBID = pac.ACTIVE_AGR_SUBID
        JOIN
            PUREGYM.AGREEMENT_CHANGE_LOG acl
        ON
            acl.AGREEMENT_CENTER = pac.ACTIVE_AGR_CENTER
            AND acl.AGREEMENT_ID = pac.ACTIVE_AGR_ID
            AND acl.AGREEMENT_SUBID = pac.ACTIVE_AGR_SUBID
            AND acl.ENTRY_TIME = max_acl.ENTRY_TIME
        LEFT JOIN
            (
                SELECT
                    pr.center,
                    pr.id,
                    MAX(pr.ENTRY_TIME) AS ENTRY_TIME
                FROM
                    params,
                    PUREGYM.PAYMENT_REQUESTS pr
                WHERE
                    pr.ENTRY_TIME <params.HARDCLOSETIME
                GROUP BY
                    pr.center,
                    pr.id) max_pr
        ON
            max_pr.center = ar.center
            AND max_pr.id = ar.id
        LEFT JOIN
            PUREGYM.PAYMENT_REQUESTS pr
        ON
            pr.CENTER = ar.CENTER
            AND pr.id = ar.id
            AND pr.ENTRY_TIME = max_pr.entry_time ) acl
ON
    acl.CUSTOMERCENTER = p.CENTER
    AND acl.CUSTOMERID = p.id
LEFT JOIN
    PUREGYM.CHECKINS ch
ON
    ch.PERSON_CENTER = p.center
    AND ch.PERSON_ID = p.id
WHERE
    p.status IN (0,2,6,9)
GROUP BY
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER || 'p' || p.ID ,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY ,
    pem.TXTVALUE ,
    ph.TXTVALUE ,
    pm.TXTVALUE ,
    CASE
        WHEN acl.text = 'Direct to OK'
            AND acl.xfr_info = 'Refer to payer'
        THEN 'PureGym cancelled'
        ELSE 'Member Cancelled'
    END ,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea_creation.txtvalue) ,
    acl.text ,
    NVL(acl.xfr_info,DECODE(acl.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manuel',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed','UNDEFINED'))