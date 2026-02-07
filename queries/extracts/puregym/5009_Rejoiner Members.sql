WITH
    PARAMS AS
    (
        SELECT
            $$scope$$                                                                               AS CENTER ,
            datetolongTZ(TO_CHAR(TRUNC(start_date , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' ) AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(end_date, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')     AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(end_date +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London')  AS HARDCLOSETIME,
            -- REJOINDURATION: in the last 365 days
            365*24*3600*1000 AS REJOINDURATION,
            -- REACTIVATEDURATION: in the last 31 days
            31*24*3600*1000 AS REINSTATEDURATION
        FROM
            (
                SELECT
                    $$start_date$$ AS start_date,
                    $$end_date$$ AS end_date
                FROM
                    DUAL )
    )
SELECT
    scl.STATEID,
    scl.SUBID,
    c.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.CENTER||'p'||p.ID pref,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.identity      AS PIN,
    email.TXTVALUE  AS Email,
    home.TXTVALUE   AS PHONEHOME,
    mobile.TXTVALUE AS Mobile
FROM
    (
        SELECT
            OWNER_CENTER,
            OWNER_ID
        FROM
            (
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
                    AND SU.CENTER IN ($$scope$$)
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
                            -- Time safety. We need to exclude subscriptions started in the past so they do
                            -- not
                            -- get
                            -- into the incoming balance because they will not be in the outgoing balance
                            -- of
                            -- the
                            -- previous day
                            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME )
                MINUS
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
                    AND SU.CENTER IN ($$scope$$)
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
                            -- Time safety. We need to exclude subscriptions started in the past so they do
                            -- not
                            -- get
                            -- into the incoming balance because they will not be in the outgoing balance
                            -- of
                            -- the
                            -- previous day
                            AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) )
        MINUS
        SELECT
            SU.OWNER_CENTER,
            SU.OWNER_ID
        FROM
            PARAMS,
            STATE_CHANGE_LOG SCL
        JOIN
            SUBSCRIPTIONS SU
        ON
            SCL.CENTER = SU.CENTER
            AND SCL.ID = SU.ID
            AND SCL.ENTRY_TYPE = 2
        JOIN
            SUBSCRIPTIONTYPES ST
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            SCL.CENTER IN ($$scope$$)
            -- we need to use entry time for time safety (retrospective sales)
            AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
            AND SCL.ENTRY_START_TIME >= PARAMS.STARTTIME
            AND SCL.ENTRY_TYPE = 2
            -- STARTTIME <= Creatd < ENDTIME
            AND SCL.STATEID = 8
            AND ST.ST_TYPE =1
            -- Not transferred (they are not joiners)
            AND SCL.SUB_STATE != 6
            AND NOT EXISTS
            (
                -- The subscription should not be ended/window the same day (cancellation)
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG SCL2
                WHERE
                    SCL2.ENTRY_TYPE = 2
                    AND SCL2.STATEID IN (3,7)
                    AND SCL2.CENTER = SU.CENTER
                    AND SCL2.ID = SU.ID
                    AND SCL2.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL2.ENTRY_START_TIME >= PARAMS.STARTTIME )
            AND NOT EXISTS
            (
                -- the member should not be in the incoming balance (otherwise not a joiner)
                --- !!! must be same SQL as incoming balance !!!
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS SU2
                JOIN
                    SUBSCRIPTIONTYPES ST2
                ON
                    SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                    AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                JOIN
                    STATE_CHANGE_LOG SCL2
                ON
                    SCL2.CENTER = SU2.CENTER
                    AND SCL2.ID = SU2.ID
                    AND SCL2.ENTRY_TYPE = 2
                WHERE
                    SU2.OWNER_CENTER = SU.OWNER_CENTER
                    AND SU2.OWNER_ID = SU.OWNER_ID
                    AND ST2.ST_TYPE =1
                    AND SCL2.STATEID IN ( 2,
                                         4,8)
                    AND SCL2.BOOK_START_TIME < PARAMS.STARTTIME
                    AND (
                        SCL2.BOOK_END_TIME IS NULL
                        OR SCL2.BOOK_END_TIME >= PARAMS.STARTTIME )
                    -- Time safety. We need to exclude subscriptions started in the past so they do
                    -- not get
                    -- into the incoming balance because they will not be in the outgoing balance
                    -- of the
                    -- previous day
                    AND SCL2.ENTRY_START_TIME < PARAMS.STARTTIME)
            AND NOT EXISTS
            (
                -- has a membership of the same type that ended in the inactivty period ?
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS SU2
                JOIN
                    SUBSCRIPTIONTYPES ST2
                ON
                    SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                    AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                JOIN
                    STATE_CHANGE_LOG SCL2
                ON
                    SCL2.CENTER = SU2.CENTER
                    AND SCL2.ID = SU2.ID
                    AND SCL2.ENTRY_TYPE = 2
                WHERE
                    SU2.OWNER_CENTER = SU.OWNER_CENTER
                    AND SU2.OWNER_ID = SU.OWNER_ID
                    AND ST2.ST_TYPE =1
                    AND SCL2.STATEID IN (3,7)
                    AND SCL2.BOOK_START_TIME < PARAMS.ENDTIME
                    AND SCL2.BOOK_START_TIME >= (SCL.BOOK_START_TIME-REJOINDURATION))
        MINUS
        SELECT DISTINCT
            OWNER_CENTER,
            OWNER_ID
        FROM
            (
                SELECT
                    SU.OWNER_CENTER,
                    SU.OWNER_ID
                FROM
                    PARAMS,
                    STATE_CHANGE_LOG SCL
                JOIN
                    SUBSCRIPTIONS SU
                ON
                    SCL.CENTER = SU.CENTER
                    AND SCL.ID = SU.ID
                    AND SCL.ENTRY_TYPE = 2
                JOIN
                    SUBSCRIPTIONTYPES ST
                ON
                    SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
                WHERE
                    SU.CENTER IN ($$scope$$)
                    -- we need to use entry time for time safety (retrospective sales)
                    AND SCL.ENTRY_START_TIME < PARAMS.ENDTIME
                    AND SCL.ENTRY_START_TIME >= PARAMS.STARTTIME
                    AND SCL.ENTRY_TYPE = 2
                    -- STARTTIME <= Creatd < ENDTIME
                    AND SCL.STATEID = 8
                    AND ST.ST_TYPE =1
                    -- Not transferred (they are not joiners)
                    AND SCL.SUB_STATE != 6
                    AND NOT EXISTS
                    (
                        -- The subscription should not be ended/window the same day (cancellation)
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL2
                        WHERE
                            SCL2.ENTRY_TYPE = 2
                            AND SCL2.STATEID IN (3,7)
                            AND SCL2.CENTER = SU.CENTER
                            AND SCL2.ID = SU.ID
                            AND SCL2.ENTRY_START_TIME < PARAMS.ENDTIME
                            AND SCL2.ENTRY_START_TIME >= PARAMS.STARTTIME )
                    AND NOT EXISTS
                    (
                        -- The subscription should not be ended/window the same day (cancellation)
                        SELECT
                            1
                        FROM
                            STATE_CHANGE_LOG SCL2
                        WHERE
                            SCL2.ENTRY_TYPE = 2
                            AND SCL2.STATEID IN (3,7)
                            AND SCL2.CENTER = SU.CENTER
                            AND SCL2.ID = SU.ID
                            AND SCL2.ENTRY_START_TIME < PARAMS.ENDTIME
                            AND SCL2.ENTRY_START_TIME >= PARAMS.STARTTIME )
                    AND NOT EXISTS
                    (
                        -- the member should not be in the incoming balance (otherwise not a joiner)
                        --- !!! must be same SQL as incoming balance !!!
                        SELECT
                            1
                        FROM
                            SUBSCRIPTIONS SU2
                        JOIN
                            SUBSCRIPTIONTYPES ST2
                        ON
                            SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                            AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                        JOIN
                            STATE_CHANGE_LOG SCL2
                        ON
                            SCL2.CENTER = SU2.CENTER
                            AND SCL2.ID = SU2.ID
                            AND SCL2.ENTRY_TYPE = 2
                        WHERE
                            SU2.OWNER_CENTER = SU.OWNER_CENTER
                            AND SU2.OWNER_ID = SU.OWNER_ID
                            AND ST2.ST_TYPE =1
                            AND SCL2.STATEID IN ( 2,
                                                 4,8)
                            AND SCL2.BOOK_START_TIME < PARAMS.STARTTIME
                            AND (
                                SCL2.BOOK_END_TIME IS NULL
                                OR SCL2.BOOK_END_TIME >= PARAMS.STARTTIME )
                            -- Time safety. We need to exclude subscriptions started in the past so they do
                            -- not get
                            -- into the incoming balance because they will not be in the outgoing balance
                            -- of the
                            -- previous day
                            AND SCL2.ENTRY_START_TIME < PARAMS.STARTTIME)
                    AND EXISTS
                    (
                        -- has a membership of the same type that ended in the inactivty period ?
                        SELECT
                            1
                        FROM
                            SUBSCRIPTIONS SU2
                        JOIN
                            SUBSCRIPTIONTYPES ST2
                        ON
                            SU2.SUBSCRIPTIONTYPE_CENTER = ST2.CENTER
                            AND SU2.SUBSCRIPTIONTYPE_ID = ST2.ID
                        JOIN
                            STATE_CHANGE_LOG SCL2
                        ON
                            SCL2.CENTER = SU2.CENTER
                            AND SCL2.ID = SU2.ID
                            AND SCL2.ENTRY_TYPE = 2
                        WHERE
                            SU2.OWNER_CENTER = SU.OWNER_CENTER
                            AND SU2.OWNER_ID = SU.OWNER_ID
                            AND ST2.ST_TYPE =1
                            AND SCL2.STATEID IN (3,7)
                            AND SCL2.BOOK_START_TIME < PARAMS.ENDTIME
                            AND SCL2.BOOK_START_TIME >= (SCL.BOOK_START_TIME - REINSTATEDURATION)) )) RJ
JOIN
    persons p
ON
    p.CENTER = RJ.owner_center
    AND p.ID = RJ.owner_id
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
JOIN
    PUREGYM.CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
CROSS JOIN
    params
LEFT JOIN
    PUREGYM.STATE_CHANGE_LOG scl
ON
    scl.ENTRY_TYPE = 5
    AND scl.STATEID = 4
    AND scl.SUB_STATE = 5
    AND scl.CENTER = p.CENTER
    AND scl.id = p.id
    AND scl.ENTRY_START_TIME BETWEEN params.starttime AND params.endtime