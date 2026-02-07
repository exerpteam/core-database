WITH
    params AS
    (
        SELECT
            TRUNC(SYSDATE-2 ,'DDD')                                                        p_date,
            datetolongTZ(TO_CHAR(SYSDATE-1 ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
        FROM
            dual
    )
SELECT DISTINCT
    P.CENTER || 'p' || P.ID AS MemberNo,
    p.CENTER                   P_CENTER,
    p.ID                       P_ID,
    p.EXTERNAL_ID ,
    c.name                                                            AS MainGymName,
    p.SEX                                                             AS Gender,
    floor(months_between(SYSDATE, p.BIRTHDATE) / 12)                  AS Age,
    NVL(SPP.SUBSCRIPTION_PRICE, NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE)) AS CURRENT_PRICE,
    NVL(SP.PRICE, SU.SUBSCRIPTION_PRICE)                              AS NORMAL_PRICE,
    CASE
        WHEN PD.GLOBALID LIKE 'DD_TIER%'
        THEN 1
        ELSE 0
    END                                                                         AS MultiSite,
    secC.NAME                                                                   AS SecondaryGym,
    cMain.NAME                                                                  AS MainGymOverride,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea_creation.txtvalue) AS MemberSinceDate,
    sua.INDIVIDUAL_PRICE_PER_UNIT                                               AS YangaPrice,
    CASE
        WHEN NOMICAL.ID IS NULL
        THEN ci.MaxExerp
        WHEN ci.MaxExerp IS NULL
        THEN NOMICAL.EVENTDATETIME
        ELSE ci.MaxExerp
    END LastGymVisit,
    CASE
        WHEN NOMICAL.ID IS NULL
        THEN ExerpLastClub.NAME
        WHEN ci.MaxExerp IS NULL
        THEN NomicalCenter.NAME
        ELSE ExerpLastClub.NAME
    END                                       LastClubVisitName,
    FrzPerMem.LastFreezeStartDate             AS LastFrozenStartDate,
    FrzPerMem.LatestFreeze                    AS LastFrozenDay,
    to_date(SYSDATE) - FrzPerMem.LatestFreeze AS "Days since last freeze",
    FrzPerMem.sums                            AS "AccumulatedFreezeDays",
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
    TRUNC(SYSDATE - p.LAST_ACTIVE_START_DATE) + 1 + p.ACCUMULATED_MEMBERDAYS "Accumulated membership",
    longtodate(latest_par.START_TIME) "LAST CLASS BOOKED DATE",
    book.NAME "LAST CLASS BOOKED NAME",
    NVL(ci.NumberOfDistinctClub,0)                CentersCount,
    NVL(ci.CountHomeClub,0)                       AS HomeClub,
    NVL(ci.CountSecondaryClub,0)                  AS SecondaryClub,
    DECODE(AEM.TXTVALUE, 'true',1,'false',0,NULL) AS "Opt in to emails",
    DECODE(ANL.TXTVALUE, 'true',1,'false',0,NULL) AS "Opt in to News Letter",
    p.BIRTHDATE,
    decode(pl_mem.is_now,0,'No','Yes') as "Current PLoser Member",
    decode(pl_mem.has_ever,0,'No','Yes') as "Past PLoser Member"
    --, latest_ci.CHECKIN_TIME
FROM
    PUREGYM.PERSONS p
CROSS JOIN
    params
    /* Check-ins */
LEFT JOIN
    (
        SELECT
            ci.PERSON_CENTER,
            ci.PERSON_ID,
            MAX(ci.id)                                                                         AS id ,
            SUM(DECODE(ci.CHECKIN_CENTER, ci.PERSON_CENTER, 1, 0))                             AS CountHomeClub ,
            SUM(DECODE(ci.CHECKIN_CENTER, ext.TXTVALUE, 1, 0))                                 AS CountSecondaryClub ,
            COUNT(DISTINCT ci.CHECKIN_CENTER)                                                  AS NumberOfDistinctClub,
            TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
        FROM
            PUREGYM.CHECKINS ci
            --join PUREGYM.PERSONS p on p.center = ci.PERSON_CENTER and p.id = ci.PERSON_ID
            --
            --and p.center = 1
        LEFT JOIN
            PUREGYM.PERSON_EXT_ATTRS ext
        ON
            ext.PERSONCENTER = ci.PERSON_CENTER
            AND ext.PERSONID = ci.PERSON_ID
            AND ext.NAME = 'SECONDARY_CENTER'
        GROUP BY
            ci.PERSON_CENTER,
            ci.PERSON_ID ) ci
ON
    ci.PERSON_CENTER = p.center
    AND ci.PERSON_ID = p.id
LEFT JOIN
    PUREGYM.CHECKINS latest_ci
ON
    latest_ci.id = ci.id
    /* Participations */
LEFT JOIN
    (
        SELECT
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID,
            MAX(par2.START_TIME) AS START_TIME
        FROM
            PUREGYM.PARTICIPATIONS par2
        WHERE
            par2.STATE IN ('PARTICIPATION',
                           'BOOKED')
        GROUP BY
            par2.PARTICIPANT_CENTER,
            par2.PARTICIPANT_ID ) par
ON
    par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.ID
LEFT JOIN
    PUREGYM.PARTICIPATIONS latest_par
ON
    latest_par.PARTICIPANT_CENTER = par.PARTICIPANT_CENTER
    AND latest_par.PARTICIPANT_ID = par.PARTICIPANT_ID
    AND latest_par.START_TIME = par.START_TIME
    AND latest_par.STATE IN ('PARTICIPATION',
                             'BOOKED')
LEFT JOIN
    PUREGYM.BOOKINGS book
ON
    book.CENTER = latest_par.BOOKING_CENTER
    AND book.ID = latest_par.BOOKING_ID
LEFT JOIN
    centers c
ON
    c.id = p.CENTER
JOIN
    PUREGYM.SUBSCRIPTIONS su
ON
    su.OWNER_CENTER = p.CENTER
    AND su.OWNER_ID = p.ID
JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    st.CENTER = su.SUBSCRIPTIONTYPE_CENTER
    AND st.id = su.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE = 1
LEFT JOIN
    PUREGYM.SUBSCRIPTIONPERIODPARTS SPP
ON
    (
        SPP.CENTER = SU.CENTER
        AND SPP.ID = SU.ID
        AND SPP.FROM_DATE <= params.p_date
        AND SPP.TO_DATE >= params.p_date
        AND SPP.SPP_STATE = 1
        AND SPP.ENTRY_TIME < params.p_start_next_day )
LEFT JOIN
    PUREGYM.SUBSCRIPTION_PRICE SP
ON
    (
        SP.SUBSCRIPTION_CENTER = SU.CENTER
        AND SP.SUBSCRIPTION_ID = SU.ID
        AND sp.CANCELLED = 0
        AND SP.FROM_DATE <= greatest(params.p_date, su.start_date)
        AND (
            SP.TO_DATE IS NULL
            OR SP.TO_DATE >= greatest(params.p_date, su.start_date) ) )
INNER JOIN
    PUREGYM.PRODUCTS PD
ON
    (
        PD.CENTER = ST.CENTER
        AND PD.ID = ST.ID )
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS pea_secgym
ON
    pea_secgym.personcenter = p.center
    AND pea_secgym.personid = p.id
    AND pea_secgym.NAME = 'SECONDARY_CENTER'
LEFT JOIN
    PUREGYM.CENTERS secC
ON
    secC.ID = pea_secgym.TXTVALUE
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS pea_maingym
ON
    pea_maingym.personcenter = p.center
    AND pea_maingym.personid = p.id
    AND pea_maingym.NAME = 'MAIN_CENTER_OVERRIDE'
LEFT JOIN
    PUREGYM.CENTERS cMain
ON
    cMain.ID = pea_maingym.TXTVALUE
JOIN
    PUREGYM.PERSON_EXT_ATTRS pea_creation
ON
    pea_creation.personcenter = p.center
    AND pea_creation.personid = p.id
    AND pea_creation.NAME = 'CREATION_DATE'
LEFT JOIN
    PUREGYM.SUBSCRIPTION_ADDON sua
ON
    sua.SUBSCRIPTION_CENTER = su.center
    AND sua.SUBSCRIPTION_ID = su.id
    AND sua.START_DATE <= p_date
    AND (
        sua.end_date IS NULL
        OR sua.end_date>= params.p_date )
    AND sua.CANCELLED = 0
LEFT JOIN
    PUREGYM.CENTERS ExerpLastClub
ON
    ExerpLastClub.id = latest_ci.CHECKIN_CENTER
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    /*this finds the supbscriptions the member has and sums their freeze sums*/
    (
        SELECT
            s.OWNER_CENTER,
            s.OWNER_ID,
            SUM(frz.freeze)              AS sums,
            MAX(frz.LastFreezeStartDate) AS LastFreezeStartDate,
            MAX(frz.Lastfreeze)          AS LatestFreeze
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            /*this finds and sums the freeze periods for each subscription the member has*/
            (
                SELECT
                    sfp.SUBSCRIPTION_ID,
                    sfp.SUBSCRIPTION_CENTER,
                    SUM ( sfp.END_DATE +1 - sfp.START_DATE ) AS freeze,
                    MAX ( sfp.START_DATE)                    AS LastFreezeStartDate,
                    MAX ( sfp.END_DATE)                      AS Lastfreeze
                FROM
                    PUREGYM.SUBSCRIPTION_FREEZE_PERIOD sfp
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
    PUREGYM.PERSON_EXT_ATTRS AEM
ON
    AEM.PERSONCENTER = p.CENTER
    AND AEM.PERSONID = p.ID
    AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ANL
ON
    ANL.PERSONCENTER = p.CENTER
    AND ANL.PERSONID = p.ID
    AND ANL.NAME = '_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    email.personcenter = p.center
    AND email.personid = p.id
    AND email.name = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
ON
    mobile.personcenter = p.center
    AND mobile.personid = p.id
    AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS workZip
ON
    workZip.personcenter = p.center
    AND workZip.personid = p.id
    AND workZip.name = 'WORK_POST_CODE'
LEFT JOIN
    NOMICAL_EVENTS NOMICAL
ON
    NOMICAL.PIN = e.IDENTITY
    AND NOMICAL.LATEST = 1
LEFT JOIN
    PUREGYM.CENTERS NomicalCenter
ON
    NomicalCenter.ID = NOMICAL.SITEID
INNER JOIN
    PUREGYM.STATE_CHANGE_LOG SCL1
ON
    (
        SCL1.CENTER = SU.CENTER
        AND SCL1.ID = SU.ID
        AND SCL1.ENTRY_TYPE = 2 )
LEFT JOIN
    (
        SELECT
            pl.OWNER_CENTER,
            pl.OWNER_ID,
            SUM(
                CASE
                    WHEN pl.STATE IN (2,4)
                    THEN 1
                    ELSE 0
                END)                          AS is_now,
            SUM(DECODE(pl.CENTER,'null',0,1)) AS has_ever
        FROM
            PUREGYM.SUBSCRIPTIONS pl
        JOIN
            PUREGYM.PRODUCTS pl_pr
        ON
            pl_pr.CENTER = pl.SUBSCRIPTIONTYPE_CENTER
            AND pl_pr.ID = pl.SUBSCRIPTIONTYPE_ID
        WHERE
            pl_pr.GLOBALID='PURE_LOSER'
        GROUP BY
            pl.OWNER_CENTER,
            pl.OWNER_ID) pl_mem
ON
    pl_mem.OWNER_CENTER = p.CENTER
    AND pl_mem.OWNER_ID = p.ID
WHERE
    SCL1.STATEID IN (2,4,8)
    AND SCL1.BOOK_START_TIME < params.p_start_next_day
    AND (
        SCL1.BOOK_END_TIME IS NULL
        OR SCL1.BOOK_END_TIME >= params.p_start_next_day )
    AND SCL1.ENTRY_START_TIME < params.p_start_next_day
    AND st.ST_TYPE = 1