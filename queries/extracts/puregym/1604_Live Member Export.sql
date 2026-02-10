-- The extract is extracted from Exerp on 2026-02-08
-- VERY HEAVY !!!
SELECT
    m.* ,
    longToDate(par.START_TIME) "LAST CLASS BOOKED DATE" ,
    book.NAME "LAST CLASS BOOKED NAME"
FROM
    (
        SELECT
            /*+ NO_BIND_AWARE */
            P.CENTER || 'p' || P.ID AS MemberNo,
            p.CENTER P_CENTER,
            p.ID P_ID,
            c.name                                                            AS MainGymName,
            p.SEX as Gender,
            floor(months_between(sysdate, p.BIRTHDATE) / 12) as Age,
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
            case 
                when NOMICAL.MaxNomical is null then center1.NAME
                when EXERP_CI.MaxExerp is null then center2.NAME
                when NOMICAL.MaxNomical > EXERP_CI.MaxExerp then center2.NAME
                else EXERP_CI.center1.NAME 
            end LastClubVisitName,
            email.TXTVALUE "EMAIL ADDRESS",
            mobile.TXTVALUE "MOBILE",
            workZip.TXTVALUE "WORK POST CODE",
            P.ZIPCODE "HOME POST CODE",
            DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
            e.IDENTITY "PIN",
            pea_relational.TXTVALUE as "TRP_RELATIONAL",
            pea_attendance.TXTVALUE as "TRP_ATTENDANCE",
            TRUNC(sysdate - p.LAST_ACTIVE_START_DATE) + 1 "Unbroken membership",
            TRUNC(sysdate - p.LAST_ACTIVE_START_DATE) + 1 + p.ACCUMULATED_MEMBERDAYS "Accumulated membership"
        FROM
            PUREGYM.SUBSCRIPTIONS SU
        CROSS JOIN
            (
                SELECT
                    TRUNC(SYSDATE-1 ,'DDD') p_date,
                    datetolongTZ(TO_CHAR(SYSDATE ,'YYYY-MM-DD') || ' 00:00', 'Europe/London') AS p_start_next_day
                FROM
                    dual
            )
            params
        JOIN PUREGYM.PERSONS P
        ON
            P.center = su.owner_center
            AND p.id = su.owner_id
        LEFT JOIN PUREGYM.ENTITYIDENTIFIERS e
        ON
            e.IDMETHOD = 5
            AND e.ENTITYSTATUS = 1
            AND e.REF_CENTER = p.CENTER
            AND e.REF_ID = p.ID
            AND e.REF_TYPE = 1
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS email
        ON
            email.personcenter = p.center
            AND email.personid = p.id
            AND email.name = '_eClub_Email'
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS mobile
        ON
            mobile.personcenter = p.center
            AND mobile.personid = p.id
            AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS workZip
        ON
            workZip.personcenter = p.center
            AND workZip.personid = p.id
            AND workZip.name = 'WORK_POST_CODE'
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_secgym
        ON
            pea_secgym.personcenter = p.center
            AND pea_secgym.personid = p.id
            AND pea_secgym.NAME = 'SECONDARY_CENTER'
        LEFT JOIN PUREGYM.CENTERS secC
        ON
            secC.ID = pea_secgym.TXTVALUE
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_secgymId
        ON
            pea_secgymId.personcenter = p.center
            AND pea_secgymId.personid = p.id
            AND pea_secgymId.NAME = 'SECONDARY_CENTER_ID'
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_maingym
        ON
            pea_maingym.personcenter = p.center
            AND pea_maingym.personid = p.id
            AND pea_maingym.NAME = 'MAIN_CENTER_OVERRIDE'
        LEFT JOIN PUREGYM.CENTERS cMain
        ON
            cMain.ID = pea_maingym.TXTVALUE
        JOIN PUREGYM.PERSON_EXT_ATTRS pea_creation
        ON
            pea_creation.personcenter = p.center
            AND pea_creation.personid = p.id
            AND pea_creation.NAME = 'CREATION_DATE'
            
        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_attendance
        ON
            pea_attendance.personcenter = p.center
            AND pea_attendance.personid = p.id
            AND pea_attendance.NAME = 'ATTENDANCE_NPS'
       LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_relational
        ON
            pea_relational.personcenter = p.center
            AND pea_relational.personid = p.id
            AND pea_relational.NAME = 'RELATIONAL_NPS'   
LEFT JOIN (
        select p.center, p.id,  trim(max(SUBSTR(NE.EVENTDATETIME, 1, 16))) as MaxNomical, NE.SITEID
                from PERSONS p
                join ENTITYIDENTIFIERS EI on ei.REF_CENTER = p.center and ei.REF_ID = p.id and ei.REF_TYPE = 1 and ei.IDMETHOD = 5
                left join NOMICAL_EVENTS NE on NE.PIN = EI.IDENTITY
                group by p.center, p.id, NE.SITEID) NOMICAL on NOMICAL.center = p.center and NOMICAL.id = p.id 
        LEFT JOIN (
                select p.center, p.id, ci.CHECKIN_CENTER,
                to_char(longtodateTZ(max(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') as MaxExerp 
                from PERSONS p
                left join PUREGYM.CHECKINS ci on ci.PERSON_CENTER = p.center and ci.PERSON_ID = p.id 
                
                group by p.center, p.id, ci.CHECKIN_CENTER
        ) EXERP_CI  on   EXERP_CI.center = p.center and EXERP_CI.id = p.id
        
        left join PUREGYM.CENTERS center1
        on center1.ID = EXERP_CI.CHECKIN_CENTER    
        
        left join PUREGYM.CENTERS center2
        on center2.ID = NOMICAL.SITEID   
            
            
        LEFT JOIN PUREGYM.SUBSCRIPTION_ADDON sua
        ON
            sua.SUBSCRIPTION_CENTER = su.center
            AND sua.SUBSCRIPTION_ID = su.id
            AND sua.START_DATE <= p_date
            AND
            (
                sua.end_date IS NULL
                OR sua.end_date>= params.p_date
            )
            AND sua.CANCELLED = 0
        JOIN PUREGYM.CENTERS c
        ON
            c.id = su.center
        INNER JOIN PUREGYM.SUBSCRIPTIONTYPES ST
        ON
            (
                SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
            )
        INNER JOIN PUREGYM.PRODUCTS PD
        ON
            (
                PD.CENTER = ST.CENTER
                AND PD.ID = ST.ID
            )
        INNER JOIN PUREGYM.STATE_CHANGE_LOG SCL1
        ON
            (
                SCL1.CENTER = SU.CENTER
                AND SCL1.ID = SU.ID
                AND SCL1.ENTRY_TYPE = 2
            )
        LEFT JOIN PUREGYM.SUBSCRIPTIONPERIODPARTS SPP
        ON
            (
                SPP.CENTER = SU.CENTER
                AND SPP.ID = SU.ID
                AND SPP.FROM_DATE <= params.p_date
                AND SPP.TO_DATE >= params.p_date
                AND SPP.SPP_STATE = 1
                AND SPP.ENTRY_TIME < params.p_start_next_day
            )
        LEFT JOIN PUREGYM.SUBSCRIPTION_PRICE SP
        ON
            (
                SP.SUBSCRIPTION_CENTER = SU.CENTER
                AND SP.SUBSCRIPTION_ID = SU.ID
                AND sp.CANCELLED = 0
                AND SP.FROM_DATE <= greatest(params.p_date, su.start_date)
                AND
                (
                    SP.TO_DATE IS NULL
                    OR SP.TO_DATE >= greatest(params.p_date, su.start_date)
                )
            )
        WHERE
            (
                SCL1.STATEID IN (2,4,8)
                AND SCL1.BOOK_START_TIME < params.p_start_next_day
                AND
                (
                    SCL1.BOOK_END_TIME IS NULL
                    OR SCL1.BOOK_END_TIME >= params.p_start_next_day
                )
                AND SCL1.ENTRY_START_TIME < params.p_start_next_day
                AND st.ST_TYPE = 1

            )
    )
    m
LEFT JOIN PUREGYM.PARTICIPATIONS par
ON
    par.PARTICIPANT_CENTER = m.P_CENTER
    AND par.PARTICIPANT_ID = m.P_ID
    AND par.STATE IN ('PARTICIPATION','BOOKED')
LEFT JOIN PUREGYM.BOOKINGS book
ON
    book.CENTER = par.BOOKING_CENTER
    AND book.ID = par.BOOKING_ID
WHERE
       (par.CENTER is null or par.START_TIME IN
    (
        SELECT
            MAX(par2.START_TIME)
        FROM
            PUREGYM.PARTICIPATIONS par2
        WHERE
            par2.PARTICIPANT_CENTER = par.PARTICIPANT_CENTER
            AND par2.PARTICIPANT_ID = par.PARTICIPANT_ID
            AND par2.STATE IN ('PARTICIPATION','BOOKED')            
    )) 