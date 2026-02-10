-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            center                                                                                                   AS CENTER ,
            datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' )                AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(add_months(currentdate,6), 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')    AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(add_months(currentdate,6) +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
        FROM
            (
                SELECT
                    add_months(c.STARTUPDATE,12) AS currentdate,
                    c.id                         AS center
                FROM
                    PUREGYM.CENTERS c
                WHERE
                    c.id IN($$scope$$))
    )
SELECT DISTINCT
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER || 'p' || p.ID AS Pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY                                                                  AS pin,
    pem.TXTVALUE                                                                AS email,
    ph.TXTVALUE                                                                 AS phoneHome,
    pm.TXTVALUE                                                                 AS mobile,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea_creation.txtvalue) AS MemberSinceDate,
    TO_CHAR(cen.STARTUPDATE,'yyyy-MM-dd')                                       AS Startup ,
    TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                            AS "Subscription end date",
    sp.PRICE                                                                    AS "Subscription From £",
    TO_CHAR(sp.FROM_DATE,'yyyy-MM-dd')                                          AS "Subscription From",
    sp2.PRICE                                                                   AS "Subscription To £",
    TO_CHAR(sp2.FROM_DATE,'yyyy-MM-dd')"Subscription To"
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
            ST.ST_TYPE IN (1)
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
            ST.ST_TYPE IN (1)
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
JOIN
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            MAX(s.END_DATE) AS END_DATE
        FROM
            PUREGYM.SUBSCRIPTIONS s
        WHERE
            s.END_DATE>s.START_DATE
        GROUP BY
            s.OWNER_CENTER,
            s.OWNER_ID ) max_s
ON
    max_s.OWNER_CENTER = p.CENTER
    AND max_s.OWNER_ID = p.id
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND s.END_DATE = max_s.end_date
CROSS JOIN
    params
JOIN
    PUREGYM.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    --AND sp.PRICE <12
    AND sp.CANCELLED = 0
    --AND sp.to_date BETWEEN longtodate(params.STARTTIME - 30) AND longtodate(params.endtime)
JOIN
    PUREGYM.SUBSCRIPTION_PRICE sp2
ON
    sp.TO_DATE =sp2.FROM_DATE -1
    AND sp2.SUBSCRIPTION_CENTER = s.CENTER
    AND sp2.SUBSCRIPTION_ID = s.id
    AND sp2.CANCELLED = 0
    --AND sp2.PRICE >14
WHERE
    sp.TO_DATE BETWEEN longtodate(params.STARTTIME) -30 AND longtodate(params.endtime)