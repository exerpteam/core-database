-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    m.* ,
    longToDate(par.START_TIME) "LAST CLASS BOOKED DATE" ,
    book.NAME "LAST CLASS BOOKED NAME",
    DECODE(AEM.TXTVALUE, 'true',1,'false',0,NULL) AS "Opt in to emails",
    DECODE(ANL.TXTVALUE, 'true',1,'false',0,NULL) AS "Opt in to News Letter"
FROM
    (
        SELECT DISTINCT
            /*+ NO_BIND_AWARE */
            P.CENTER || 'p' || P.ID AS MemberNo,
            p.CENTER                   P_CENTER,
            p.ID                       P_ID,
            p.EXTERNAL_ID,
            c.name                                                            AS MainGymName,
            p.SEX                                                             AS Gender,
            floor(months_between(SYSDATE, p.BIRTHDATE) / 12)                  AS Age,
            COALESCE(SPP.SUBSCRIPTION_PRICE, COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)) AS CURRENT_PRICE,
            COALESCE(SP.PRICE, SU.SUBSCRIPTION_PRICE)                              AS NORMAL_PRICE,
            CASE
                WHEN PD.GLOBALID LIKE 'DD_TIER%'
                THEN 1
                ELSE 0
            END                                                                         AS MultiSite,
            secC.NAME                                                                   AS SecondaryGym,
            cMain.NAME                                                                  AS MainGymOverride,
            COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea_creation.txtvalue) AS MemberSinceDate,
            sua.INDIVIDUAL_PRICE_PER_UNIT                                               AS YangaPrice,
            --            NOMICAL.MaxNomical, EXERP_CI.MaxExerp,
            CASE
                WHEN NOMICAL.MaxNomical IS NULL
                THEN EXERP_CI.MaxExerp
                WHEN EXERP_CI.MaxExerp IS NULL
                THEN NOMICAL.MaxNomical
                WHEN NOMICAL.MaxNomical > EXERP_CI.MaxExerp
                THEN NOMICAL.MaxNomical
                ELSE EXERP_CI.MaxExerp
            END LastGymVisit,
            CASE
                WHEN NOMICAL.MaxNomical IS NULL
                THEN center1.NAME
                WHEN EXERP_CI.MaxExerp IS NULL
                THEN center2.NAME
                WHEN NOMICAL.MaxNomical > EXERP_CI.MaxExerp
                THEN center2.NAME
                ELSE EXERP_CI.center1.NAME
            END                                       LastClubVisitName,
            FrzDayStart.LastFreezeStartDate           AS LastFrozenStartDate,
            FrzPerMem.LatestFreeze                    AS LastFrozenDay,
            to_date(SYSDATE) - FrzPerMem.LatestFreeze AS "Days since last freeze",
            FrzPerMem.sums                            AS "AccumilatedFreezeDays",
            P.FIRSTNAME                                  "FIRSTNAME",
            P.LASTNAME                                   "LASTNAME",
            email.TXTVALUE "EMAIL ADDRESS",
            mobile.TXTVALUE "MOBILE",
            workZip.TXTVALUE "WORK POST CODE",
            P.ZIPCODE "HOME POST CODE",
            DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
            DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS PERSONTYPE,
            e.IDENTITY                                                                                                                                                                         "PIN",
            TRUNC(SYSDATE - p.LAST_ACTIVE_START_DATE) + 1 "Unbroken membership",
            TRUNC(SYSDATE - p.LAST_ACTIVE_START_DATE) + 1 + p.ACCUMULATED_MEMBERDAYS "Accumulated membership"
        FROM
            SUBSCRIPTIONS SU
        CROSS JOIN
            (
                SELECT
                    TRUNC(SYSDATE-1 ,'DDD')                                                      p_date,
                    datetolongTZ(TO_CHAR(SYSDATE ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
                 ) params
        JOIN
            PERSONS P
        ON
            P.center = su.owner_center
            AND p.id = su.owner_id
        LEFT JOIN
            ENTITYIDENTIFIERS e
        ON
            e.IDMETHOD = 5
            AND e.ENTITYSTATUS = 1
            AND e.REF_CENTER = p.CENTER
            AND e.REF_ID = p.ID
            AND e.REF_TYPE = 1
        LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            email.personcenter = p.center
            AND email.personid = p.id
            AND email.name = '_eClub_Email'
        LEFT JOIN
            PERSON_EXT_ATTRS mobile
        ON
            mobile.personcenter = p.center
            AND mobile.personid = p.id
            AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
            PERSON_EXT_ATTRS workZip
        ON
            workZip.personcenter = p.center
            AND workZip.personid = p.id
            AND workZip.name = 'WORK_POST_CODE'
        LEFT JOIN
            PERSON_EXT_ATTRS pea_secgym
        ON
            pea_secgym.personcenter = p.center
            AND pea_secgym.personid = p.id
            AND pea_secgym.NAME = 'SECONDARY_CENTER'
        LEFT JOIN
            CENTERS secC
        ON
            secC.ID = pea_secgym.TXTVALUE
        LEFT JOIN
            PERSON_EXT_ATTRS pea_secgymId
        ON
            pea_secgymId.personcenter = p.center
            AND pea_secgymId.personid = p.id
            AND pea_secgymId.NAME = 'SECONDARY_CENTER_ID'
        LEFT JOIN
            PERSON_EXT_ATTRS pea_maingym
        ON
            pea_maingym.personcenter = p.center
            AND pea_maingym.personid = p.id
            AND pea_maingym.NAME = 'MAIN_CENTER_OVERRIDE'
        LEFT JOIN
            CENTERS cMain
        ON
            cMain.ID = pea_maingym.TXTVALUE
        JOIN
            PERSON_EXT_ATTRS pea_creation
        ON
            pea_creation.personcenter = p.center
            AND pea_creation.personid = p.id
            AND pea_creation.NAME = 'CREATION_DATE'
        LEFT JOIN
            (
                SELECT
                    ei.REF_CENTER,
                    ei.REF_ID,
                    trim(MAX(SUBSTR(NE.EVENTDATETIME, 1, 16))) AS MaxNomical
                FROM
                    ENTITYIDENTIFIERS EI
                LEFT JOIN
                    NOMICAL_EVENTS NE
                ON
                    NE.PIN = EI.IDENTITY
                WHERE
                    ei.REF_TYPE = 1
                    AND ei.IDMETHOD = 5
                GROUP BY
                    REF_CENTER,
                    ei.REF_ID) MaxNOMICAL
        ON
            MaxNOMICAL.REF_CENTER = p.center
            AND MaxNOMICAL.REF_ID = p.id
        LEFT JOIN
            (
                SELECT
                    ei.REF_CENTER,
                    ei.REF_ID,
                    trim(SUBSTR(NE.EVENTDATETIME, 1, 16)) AS MaxNomical,
                    NE.SITEID
                FROM
                    ENTITYIDENTIFIERS EI
                LEFT JOIN
                    NOMICAL_EVENTS NE
                ON
                    NE.PIN = EI.IDENTITY
                WHERE
                    ei.REF_TYPE = 1
                    AND ei.IDMETHOD = 5
                GROUP BY
                    REF_CENTER,
                    ei.REF_ID,
                    trim(SUBSTR(NE.EVENTDATETIME, 1, 16)),
                    NE.SITEID) NOMICAL
        ON
            NOMICAL.REF_CENTER = p.center
            AND NOMICAL.REF_ID = p.id
            AND NOMICAL.MaxNomical = MaxNOMICAL.MaxNomical
        LEFT JOIN
            (
                SELECT
                    ci.PERSON_CENTER ,
                    ci.PERSON_ID ,
                    TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
                FROM
                    CHECKINS ci
                GROUP BY
                    ci.PERSON_CENTER ,
                    ci.PERSON_ID ) MAXEXERP_CI
        ON
            MAXEXERP_CI.PERSON_CENTER = p.center
            AND MAXEXERP_CI.PERSON_ID = p.id
        LEFT JOIN
            (
                SELECT
                    ci.PERSON_CENTER ,
                    ci.PERSON_ID ,
                    TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp,
                    ci.CHECKIN_CENTER
                FROM
                    CHECKINS ci
                GROUP BY
                    ci.PERSON_CENTER ,
                    ci.PERSON_ID,
                    TO_CHAR(longtodateTZ(ci.CHECKIN_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI'),
                    ci.CHECKIN_CENTER ) EXERP_CI
        ON
            EXERP_CI.PERSON_CENTER = p.center
            AND EXERP_CI.PERSON_ID = p.id
            AND EXERP_CI.MaxExerp = MAXEXERP_CI.MaxExerp
        LEFT JOIN
            CENTERS center1
        ON
            center1.ID = EXERP_CI.CHECKIN_CENTER
        LEFT JOIN
            CENTERS center2
        ON
            center2.ID = NOMICAL.SITEID
        LEFT JOIN
            SUBSCRIPTION_ADDON sua
        ON
            sua.SUBSCRIPTION_CENTER = su.center
            AND sua.SUBSCRIPTION_ID = su.id
            AND sua.START_DATE <= p_date
            AND (
                sua.end_date IS NULL
                OR sua.end_date>= params.p_date )
            AND sua.CANCELLED = 0
        JOIN
            CENTERS c
        ON
            c.id = su.center
        INNER JOIN
            SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID )
        INNER JOIN
            PRODUCTS PD
        ON
            (
                PD.CENTER = ST.CENTER
                AND PD.ID = ST.ID )
        INNER JOIN
            STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2 )
        LEFT JOIN
            SUBSCRIPTIONPERIODPARTS SPP
        ON
            (
                SPP.CENTER = SU.CENTER
                AND SPP.ID = SU.ID
                AND SPP.FROM_DATE <= params.p_date
                AND SPP.TO_DATE >= params.p_date
                AND SPP.SPP_STATE = 1
                AND SPP.ENTRY_TIME < params.p_start_next_day )
        LEFT JOIN
            /*this finds the supbscriptions the member has and sums their freeze sums*/
            (
                SELECT
                    s.OWNER_CENTER,
                    s.OWNER_ID,
                    SUM(frz.freeze) AS sums
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    /*this finds and sums the freeze periods for each subscription the member has*/
                    (
                        SELECT
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER,
                            SUM ( sfp.END_DATE +1 - sfp.START_DATE ) AS freeze
                        FROM
                            SUBSCRIPTION_FREEZE_PERIOD sfp
                        WHERE
                            sfp.STATE = 'ACTIVE'
                        GROUP BY
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER ) frz
                ON
                    frz.SUBSCRIPTION_CENTER = s.CENTER
                    AND frz.SUBSCRIPTION_ID = s.ID
                GROUP BY
                    s.OWNER_CENTER,
                    s.OWNER_ID ) FrzPerMem
        ON
            p.ID = FrzPerMem.OWNER_ID
            AND p.CENTER = FrzPerMem.OWNER_CENTER
        LEFT JOIN
            (
                SELECT
                    s.OWNER_CENTER,
                    s.OWNER_ID,
                    MAX(frz.LastFreezeStartDate) AS LastFreezeStartDate
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    (
                        SELECT
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER,
                            MAX ( sfp.START_DATE) AS LastFreezeStartDate
                        FROM
                            SUBSCRIPTION_FREEZE_PERIOD sfp
                        WHERE
                            sfp.STATE = 'ACTIVE'
                        GROUP BY
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER ) frz
                ON
                    frz.SUBSCRIPTION_CENTER = s.CENTER
                    AND frz.SUBSCRIPTION_ID = s.ID
                GROUP BY
                    s.OWNER_CENTER,
                    s.OWNER_ID ) FrzDayStart
        ON
            p.ID = FrzDayStart.OWNER_ID
            AND p.CENTER = FrzDayStart.OWNER_CENTER
        LEFT JOIN
            (
                SELECT
                    s.OWNER_CENTER,
                    s.OWNER_ID,
                    MAX(frz.Lastfreeze) AS LatestFreeze
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    (
                        SELECT
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER,
                            MAX ( sfp.END_DATE) AS Lastfreeze
                        FROM
                            SUBSCRIPTION_FREEZE_PERIOD sfp
                        WHERE
                            sfp.STATE = 'ACTIVE'
                        GROUP BY
                            sfp.SUBSCRIPTION_ID,
                            sfp.SUBSCRIPTION_CENTER ) frz
                ON
                    frz.SUBSCRIPTION_CENTER = s.CENTER
                    AND frz.SUBSCRIPTION_ID = s.ID
                GROUP BY
                    s.OWNER_CENTER,
                    s.OWNER_ID ) FrzPerMem
        ON
            p.ID = FrzPerMem.OWNER_ID
            AND p.CENTER = FrzPerMem.OWNER_CENTER
        LEFT JOIN
            SUBSCRIPTION_PRICE SP
        ON
            (
                SP.SUBSCRIPTION_CENTER = SU.CENTER
                AND SP.SUBSCRIPTION_ID = SU.ID
                AND sp.CANCELLED = 0
                AND SP.FROM_DATE <= greatest(params.p_date, su.start_date)
                AND (
                    SP.TO_DATE IS NULL
                    OR SP.TO_DATE >= greatest(params.p_date, su.start_date) ) )
        WHERE
            (
                SCL1.STATEID IN (2,4,8)
                AND SCL1.BOOK_START_TIME < params.p_start_next_day
                AND (
                    SCL1.BOOK_END_TIME IS NULL
                    OR SCL1.BOOK_END_TIME >= params.p_start_next_day )
                AND SCL1.ENTRY_START_TIME < params.p_start_next_day
                AND st.ST_TYPE = 1) ) m
LEFT JOIN
    (
        SELECT
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID,
            MAX(par2.START_TIME) AS START_TIME
        FROM
            PARTICIPATIONS par2
        WHERE
            par2.STATE IN ('PARTICIPATION',
                           'BOOKED')
        GROUP BY
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID ) LastParticipation
ON
    LastParticipation.PARTICIPANT_CENTER = m.P_CENTER
    AND LastParticipation.PARTICIPANT_ID=m.P_ID
LEFT JOIN
    PARTICIPATIONS par
ON
    par.PARTICIPANT_CENTER = m.P_CENTER
    AND par.PARTICIPANT_ID = m.P_ID
    AND par.START_TIME = LastParticipation.START_TIME
LEFT JOIN
    BOOKINGS book
ON
    book.CENTER = par.BOOKING_CENTER
    AND book.ID = par.BOOKING_ID
LEFT JOIN
    PERSON_EXT_ATTRS AEM
ON
    AEM.PERSONCENTER = m.P_CENTER
    AND AEM.PERSONID = m.P_ID
    AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS ANL
ON
    ANL.PERSONCENTER = m.P_CENTER
    AND ANL.PERSONID = m.P_ID
    AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'