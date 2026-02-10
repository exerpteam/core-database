-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
            --  $$center$$
            -- AS CENTER ,
            datetolongTZ(TO_CHAR(TRUNC(currentdate , 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London' )  AS STARTTIME ,
            datetolongTZ(TO_CHAR(TRUNC(currentdate +1, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME,
            datetolongTZ(TO_CHAR(TRUNC(currentdate +2, 'DDD'), 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS HARDCLOSETIME
        FROM
            (
                SELECT
                    $$thedate$$ AS currentdate
                FROM
                    DUAL )
    )
    ,
    INCLUDED_ST AS
    (
        SELECT DISTINCT
            st1.center,
            st1.id
        FROM
            SUBSCRIPTIONTYPES st1
        CROSS JOIN
            params
        WHERE
            (
                st1.center, st1.id) NOT IN
            (
                SELECT
                    center,
                    id
                FROM
                    V_EXCLUDED_SUBSCRIPTIONS )
    )
SELECT
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id AS MemberID,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY                                                             AS PIN,
    email.TXTVALUE                                                         AS Email,
    home.TXTVALUE                                                          AS PHONEHOME,
    mobile.TXTVALUE                                                        AS MOBILE,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue)     AS MemberSinceDate,
    TO_CHAR(longtodatetz(MAX(xx.CREATION_TIME),'Europe/London'),'HH24:MI') AS MemberSinceTime,
    TO_CHAR(longtodateTZ(MAX(ch.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS CHECKIN_TIME,
    DECODE(Yes_PT.NUMBER_ANSWER,1,'yes',2,'no',NULL) AS "PT" ,
    newsletter.TXTVALUE                              AS "Newsletter",
    offers.TXTVALUE                                  AS "3rd party offers" ,
    staff.FULLNAME                                   AS Sale_Staff
FROM
    (
        -- Outoing balance members
        SELECT DISTINCT
            SU.OWNER_CENTER AS CENTER,
            SU.OWNER_ID     AS ID,
            su.CREATOR_CENTER,
            su.CREATOR_ID,
            su.CREATION_TIME
        FROM
            PARAMS,
            INCLUDED_ST ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            -- ST.ST_TYPE = 1
            --(ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
            --        AND
            SU.CENTER IN ($$center$$)
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
            SU.OWNER_CENTER AS CENTER,
            SU.OWNER_ID     AS ID,
            su.CREATOR_CENTER,
            su.CREATOR_ID,
            su.CREATION_TIME
        FROM
            PARAMS,
            INCLUDED_ST ST
        JOIN
            SUBSCRIPTIONS SU
        ON
            SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
            AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
        WHERE
            --   ST.ST_TYPE = 1
            --         (ST.CENTER, ST.ID) not in (select /*+ materialize */ center, id from V_EXCLUDED_SUBSCRIPTIONS) -- 17/09/2015 ST-421 Changed from st type = 1
            --        AND
            SU.CENTER IN ($$center$$)
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
                    AND SCL.ENTRY_START_TIME < PARAMS.STARTTIME ) ) xx
JOIN
    PUREGYM.PERSONS p
ON
    xx.CENTER = p.center
    AND xx.ID = p.id
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
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    p.center=pea.PERSONCENTER
    AND p.id=pea.PERSONID
    AND pea.name='CREATION_DATE'
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    PUREGYM.EMPLOYEES emp
ON
    emp.center = xx.CREATOR_CENTER
    AND emp.id = xx.CREATOR_ID
LEFT JOIN
    PUREGYM.PERSONS staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
    /*LEFT JOIN
    (
    SELECT
    ch.person_center,
    ch.person_ID,
    --      max(ch.CHECKIN_TIME)
    TO_CHAR(longtodateTZ(MAX(ch.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS CHECKIN_TIME
    FROM
    PUREGYM.CHECKINS ch
    GROUP BY
    ch.person_center,
    ch.person_ID) last_chkin
    ON
    last_chkin.person_center =xx.center
    AND last_chkin.person_ID = xx.id*/
LEFT JOIN
    PUREGYM.CHECKINS ch
ON
    p.center = ch.PERSON_CENTER
    AND p.id = ch.PERSON_ID
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    p.center,
                    p.id,
                    qa.NUMBER_ANSWER,
                    rank() over (partition BY p.center, p.id ORDER BY qun.LOG_TIME DESC) AS rnk
                FROM
                    QUESTION_ANSWER QA
                JOIN
                    QUESTIONNAIRE_ANSWER QUN
                ON
                    QA.ANSWER_CENTER = QUN.CENTER
                    AND QA.ANSWER_ID = QUN.ID
                    AND QA.ANSWER_SUBID = QUN.SUBID
                JOIN
                    PUREGYM.QUESTIONNAIRE_CAMPAIGNS QC
                ON
                    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
                JOIN
                    PUREGYM.QUESTIONNAIRES Q
                ON
                    q.ID = QC.QUESTIONNAIRE
                JOIN
                    PUREGYM.PERSONS p
                ON
                    QUN.CENTER = P.CENTER
                    AND QUN.ID = P.ID
                WHERE
                    Q.NAME = 'Marketing Questionnaire'
                    AND p.sex !='C'
                    AND qa.QUESTION_ID = 3
                    AND qun.COMPLETED = 1 )
        WHERE
            rnk = 1) Yes_PT
ON
    Yes_PT.center = xx.center
    AND Yes_PT.id = xx.id
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS newsletter
ON
    xx.center=newsletter.PERSONCENTER
    AND xx.id=newsletter.PERSONID
    AND newsletter.name='eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS offers
ON
    xx.center=offers.PERSONCENTER
    AND xx.id=offers.PERSONID
    AND offers.name='eClubIsAcceptingThirdPartyOffers'
GROUP BY
    cen.NAME,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id ,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e.IDENTITY ,
    email.TXTVALUE ,
    home.TXTVALUE ,
    mobile.TXTVALUE ,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue),
    DECODE(Yes_PT.NUMBER_ANSWER,1,'yes',2,'no',NULL),
    newsletter.TXTVALUE,
    offers.TXTVALUE,
    staff.FULLNAME