WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            to_date(TO_CHAR(longtodateC($$B_STOP$$,100),'yyyy-MM-dd'),'yyyy-MM-dd')               AS B_STOP_DATE,
            add_months(to_date(TO_CHAR(longtodateC($$B_STOP$$,100),'yyyy-MM-dd'),'yyyy-MM-dd'),1) AS C_STOP_DATE
        FROM
            dual
    )
SELECT
    dms."PERSON_ID",
    dms."PERSON_KEY_CENTER"||'p'||dms."PERSON_KEY_ID" AS "PERSON_KEY",
    dms."PERSON_KEY_CENTER"                           AS "PERSON_CENTER",
    -- dms.MIGRATION_DATE                                AS "MIGRATION_DATE",
    -- PERSON_CENTER
    --HasLoggedInMemberMobileApp
    --HASLOGGEDINWEB
    params.C_STOP_DATE                                                                                                                                                                             AS "EXTRACT_C_STOP",
    dms."GENDER"                                                                                                                                                                                   AS "GENDER",
    DECODE (dms."PERSON_TYPE", 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9, 'CHILD', 10, 'EXTERNAL_STAFF','UNKNOWN') AS "PERSON_TYPE",
    FLOOR((params.B_STOP_DATE - "BIRTHDATE")/365)                                                                                                                                                  AS "AGE",
    DECODE("MEMBER_AT_C_STOP",0,1,0)                                                                                                                                                               AS "CHURN",
    "CHANGE_IN_CHURN_DURATION",
    CASE
        WHEN "MEMBER_AT_C_STOP" = 0
        THEN "LAST_C"
        ELSE NULL
    END             AS "LAST_C",
    dms."STOP_DATE" AS "STOP_DATE",
    "CANCEL_AGREEMENT" ,
    /*    ma."JOINED_MOBILE_APP",
    */
    params.B_STOP_DATE - "JOIN_DATE"                      AS "TENURE_DAYS",
    NVL(dms."VISITS_COUNT",0)                             AS "VISITS_COUNT",
    NVL(dms.DAYS_LAST_VISITS,B_STOP_DATE-dms."JOIN_DATE") AS "DAYS_LAST_VISITS",
    NVL("PAR_SHOWUPS",0)                                  AS "PAR_SHOWUPS",
    NVL("PAR_NO_SHOWS" ,0)                                AS "PAR_NO_SHOWS",
    NVL("PAR_USER_CANCEL",0)                              AS "PAR_USER_CANCEL",
    sub_period."SUB_PERIOD_PRICE_TOTAL"                   AS "SUB_PERIOD_PRICE_TOATL",
    FLOOR(NVL(dms.WEEK1_DUR,0))                           AS "VD_WEEK1",
    NVL(dms.WEEK1,0)                                      AS "VF_WEEK1",
    NVL(dms.WEEK2,0)                                      AS "VF_WEEK2",
    NVL(dms.WEEK3,0)                                      AS "VF_WEEK3",
    NVL(dms.WEEK4,0)                                      AS "VF_WEEK4",
    NVL(dms.WEEK5,0)                                      AS "VF_WEEK5",
    NVL(dms.WEEK6,0)                                      AS "VF_WEEK6",
    NVL(dms.WEEK7,0)                                      AS "VF_WEEK7",
    NVL(dms.WEEK8,0)                                      AS "VF_WEEK8",
    NVL(dms.WEEK9,0)                                      AS "VF_WEEK9",
    NVL(dms.WEEK10,0)                                     AS "VF_WEEK10",
    NVL(dms.WEEK11,0)                                     AS "VF_WEEK11",
    NVL(dms.WEEK12,0)                                     AS "VF_WEEK12",
    NVL(dms.WEEK1-dms.WEEK2,0)                            AS "VFD_WEEK1",
    NVL(dms.WEEK2-dms.WEEK3,0)                            AS "VFD_WEEK2",
    NVL(dms.WEEK3-dms.WEEK4,0)                            AS "VFD_WEEK3",
    NVL(dms.WEEK4-dms.WEEK5,0)                            AS "VFD_WEEK4",
    NVL (dms.WEEK5-dms.WEEK6,0)                           AS "VFD_WEEK5",
    NVL(dms.WEEK6-dms.WEEK7,0)                            AS "VFD_WEEK6",
    NVL(dms.WEEK7-dms.WEEK8,0)                            AS "VFD_WEEK7",
    NVL(dms.WEEK8-dms.WEEK9,0)                            AS "VFD_WEEK8",
    NVL(dms.WEEK9-dms.WEEK10,0)                           AS "VFD_WEEK9",
    NVL(dms.WEEK10-dms.WEEK11,0)                          AS "VFD_WEEK10",
    NVL(dms.WEEK11-dms.WEEK12,0)                          AS "VFD_WEEK11"
FROM
    params,
    (
        SELECT
            *
        FROM
            (
                SELECT
                    dms."PERSON_ID",
                    "PERSON_KEY_CENTER",
                    "PERSON_KEY_ID",
                    dms."BIRTHDATE",
                    dms."PERSON_TYPE",
                    dms."GENDER",
                    "MEMBER_AT_B_START",
                    "MEMBER_AT_B_STOP",
                    "MEMBER_AT_C_STOP",
                    "CHANGE_IN_CHURN_DURATION",
                    longtodateC("LAST_C","PERSON_KEY_CENTER") AS "LAST_C",
                    "JOIN_DATE",
                    "MIGRATION_DATE",
                    longtodateC(STOP_TIME,"PERSON_KEY_CENTER") AS "STOP_DATE",
                    CANCEL_AGREEMENT                           AS "CANCEL_AGREEMENT",
                    COUNT( DISTINCT
                    CASE
                        WHEN c.CHECKIN_TIME > STOP_TIME - (12*7*1000*60*60*24)
                        THEN c.id
                        ELSE NULL
                    END) over (partition BY dms."PERSON_ID") AS "VISITS_COUNT",
                    COUNT(DISTINCT
                    CASE
                        WHEN par.STARTTIME BETWEEN STOP_TIME - (12*7*1000*60*60*24) AND STOP_TIME
                            AND par.STATE IN('PARTICIPATION')
                        THEN par_id
                        ELSE NULL
                    END) over (partition BY dms."PERSON_ID") AS "PAR_SHOWUPS",
                    COUNT(DISTINCT
                    CASE
                        WHEN par.STARTTIME BETWEEN STOP_TIME - (12*7*1000*60*60*24) AND STOP_TIME
                            AND par.STATE IN('CANCELLED')
                            AND par.CANCELATION_REASON IN('NO_SHOW')
                        THEN par_id
                        ELSE NULL
                    END) over (partition BY dms."PERSON_ID") AS "PAR_NO_SHOWS",
                    COUNT(DISTINCT
                    CASE
                        WHEN par.STARTTIME BETWEEN STOP_TIME - (12*7*1000*60*60*24) AND STOP_TIME
                            AND par.STATE IN('CANCELLED')
                            AND par.CANCELATION_REASON IN('USER',
                                                          'USER_CANCEL_LATE')
                        THEN par_id
                        ELSE NULL
                    END) over (partition BY dms."PERSON_ID") AS "PAR_USER_CANCEL",
                    COUNT(DISTINCT
                    CASE
                        WHEN par.STARTTIME > STOP_TIME
                            AND par.STATE NOT IN('CANCELLED')
                        THEN par_id
                        ELSE NULL
                    END) over (partition BY dms."PERSON_ID")                                                    AS "PAR_FUTURE",
                    ROUND((STOP_TIME- MAX(c.CHECKIN_TIME) over (partition BY dms."PERSON_ID"))/(1000*60*60*24)) AS DAYS_LAST_VISITS,
                    ROUND(AVG (
                        CASE
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 1
                            THEN floor((c.CHECKOUT_TIME - c.CHECKIN_TIME)/(1000*60))
                            ELSE NULL
                        END) over (partition BY dms."PERSON_ID")) AS WEEK1_DUR,
                    c.id                                          AS C_ID,
                    (
                        CASE
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 1
                            THEN 'WEEK1'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 2
                            THEN 'WEEK2'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 3
                            THEN 'WEEK3'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 4
                            THEN 'WEEK4'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 5
                            THEN 'WEEK5'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 6
                            THEN 'WEEK6'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 7
                            THEN 'WEEK7'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 8
                            THEN 'WEEK8'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 9
                            THEN 'WEEK9'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 10
                            THEN 'WEEK10'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 11
                            THEN 'WEEK11'
                            WHEN floor(((STOP_TIME - c.CHECKIN_TIME)/(1000*60*60*24))/7)+1 = 12
                            THEN 'WEEK12'
                            ELSE NULL
                        END) WEEK_NO
                FROM
                    ( --Defines
                        SELECT
                            EXTERNAL_ID AS "PERSON_ID",
                            CENTER      AS "PERSON_KEY_CENTER",
                            ID          AS "PERSON_KEY_ID",
                            BIRTHDATE   AS "BIRTHDATE",
                            PERSONTYPE  AS "PERSON_TYPE",
                            SEX         AS "GENDER",
                            SUM(
                                CASE
                                    WHEN dms.CHANGE_DATE < params.B_STOP_DATE- (12*7)
                                    THEN dms.MEMBER_NUMBER_DELTA
                                    ELSE 0
                                END) AS "MEMBER_AT_B_START",
                            SUM(
                                CASE
                                    WHEN dms.CHANGE_DATE < params.B_STOP_DATE
                                    THEN dms.MEMBER_NUMBER_DELTA
                                    ELSE 0
                                END) AS "MEMBER_AT_B_STOP",
                            SUM(
                                CASE
                                    WHEN dms.CHANGE_DATE < params.C_STOP_DATE
                                    THEN dms.MEMBER_NUMBER_DELTA
                                    ELSE 0
                                END) AS "MEMBER_AT_C_STOP",
                            SUM(
                                CASE
                                    WHEN dms.CHANGE_DATE BETWEEN params.C_STOP_DATE AND add_months(params.C_STOP_DATE,$$MIN_C_DUR$$)
                                    THEN 1
                                    ELSE 0
                                END) AS "CHANGE_IN_CHURN_DURATION",
                            MAX(
                                CASE
                                    WHEN dms.MEMBER_NUMBER_DELTA = -1
                                        AND dms.CHANGE IN (4,5,6)
                                    THEN (dms.CHANGE_DATE - to_date('1970-01-01','yyyy-MM-dd')) *1000*60*60*24
                                    ELSE NULL
                                END) AS "LAST_C",
                            MIN(
                                CASE
                                    WHEN dms.MEMBER_NUMBER_DELTA = 1
                                    THEN dms.CHANGE_DATE
                                    ELSE NULL
                                END)              AS "JOIN_DATE",
                            MAX(LASTUPDATED)      AS "MIGRATION_DATE",
                            MAX(STOP_TIME)        AS STOP_TIME,
                            MAX(CANCEL_AGREEMENT) AS CANCEL_AGREEMENT
                        FROM
                            params,
                            (
                                SELECT
                                    cp.EXTERNAL_ID,
                                    p.center AS p_center,
                                    p.id     AS p_id,
                                    --   longtodateC(scStop.CHANGE_TIME, cp.center) AS CHANGE_DATE,
                                    dms.change_date,
                                    dms.ENTRY_START_TIME,
                                    cp.BIRTHDATE,
                                    cp.CENTER,
                                    cp.ID,
                                    cp.PERSONTYPE,
                                    cp.SEX,
                                    dms.MEMBER_NUMBER_DELTA,
                                    dms.CHANGE,
                                    MAX(ces.LASTUPDATED)                                                     AS LASTUPDATED,
                                    rank() over ( partition BY cp.EXTERNAL_ID ORDER BY dms.CHANGE_DATE DESC) AS rnk,
                                    --  TRUNC(longtodateC(MAX(scStop.CHANGE_TIME),cp.center))                    AS change_date,
                                    MAX(DECODE(acl.ACL_LOG_TIME,NULL,0,1))         AS CANCEL_AGREEMENT,
                                    MIN(NVL(acl.ACL_LOG_TIME, scStop.CHANGE_TIME)) AS STOP_TIME
                                FROM
                                    params,
                                    DAILY_MEMBER_STATUS_CHANGES dms
                                JOIN
                                    persons p
                                ON
                                    p.center = dms.PERSON_CENTER
                                    AND p.id = dms.PERSON_ID
                                JOIN
                                    persons cp
                                ON
                                    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                                    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                                LEFT JOIN
                                    CONVERTER_ENTITY_STATE ces
                                ON
                                    ces.ENTITYTYPE = 'person'
                                    AND ces.NEWENTITYCENTER = p.center
                                    AND ces.NEWENTITYID = p.id
                                LEFT JOIN
                                    (
                                        SELECT
                                            s.OWNER_CENTER,
                                            s.OWNER_ID,
                                            s.center,
                                            s.id,
                                            scl.BOOK_START_TIME
                                        FROM
                                            SUBSCRIPTIONS s
                                        JOIN
                                            STATE_CHANGE_LOG scl
                                        ON
                                            scl.ENTRY_TYPE = 2
                                            AND scl.center = s.center
                                            AND scl.id = s.id) s
                                ON
                                    s.OWNER_CENTER = dms.PERSON_CENTER
                                    AND s.OWNER_ID = dms.PERSON_ID
                                    AND s.BOOK_START_TIME BETWEEN (dms.CHANGE_DATE - to_date('1970-01-01','yyyy-MM-dd')) *1000*60*60*24 AND (
                                        dms.CHANGE_DATE +1 - to_date('1970-01-01','yyyy-MM-dd')) *1000*60*60*24 + 1000*60*60--dms.ENTRY_START_TIME -1000 AND dms.ENTRY_START_TIME +1000
                                LEFT JOIN -- Workaround to avoid bug including duplicate scStop entries
                                    (
                                        SELECT
                                            scStop.OLD_SUBSCRIPTION_CENTER,
                                            scStop.OLD_SUBSCRIPTION_ID,
                                            MAX(scStop.CHANGE_TIME) AS CHANGE_TIME
                                        FROM
                                            SUBSCRIPTION_CHANGE scStop
                                        WHERE
                                            scStop.TYPE = 'END_DATE'
                                            AND scStop.CANCEL_TIME IS NULL
                                        GROUP BY
                                            scStop.OLD_SUBSCRIPTION_CENTER,
                                            scStop.OLD_SUBSCRIPTION_ID ) scStop
                                ON
                                    scStop.OLD_SUBSCRIPTION_CENTER = s.CENTER
                                    AND scStop.OLD_SUBSCRIPTION_ID = s.ID
                                LEFT JOIN
                                    (
                                        SELECT
                                            acl.AGREEMENT_CENTER,
                                            acl.AGREEMENT_ID,
                                            acl.AGREEMENT_SUBID,
                                            ar.CUSTOMERCENTER,
                                            ar.CUSTOMERID,
                                            acl.ENTRY_TIME                                                                                                   AS ACL_ENTRY_TIME,
                                            (acl.LOG_DATE- to_date('1970-01-01','yyyy-MM-dd')) *1000*60*60*24                                                AS ACL_LOG_TIME,
                                            rank() over (partition BY acl.AGREEMENT_CENTER, acl.AGREEMENT_ID, acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE ASC) AS rnk
                                        FROM
                                            PUREGYM.AGREEMENT_CHANGE_LOG acl
                                        JOIN
                                            PUREGYM.ACCOUNT_RECEIVABLES ar
                                        ON
                                            ar.center = acl.AGREEMENT_CENTER
                                            AND ar.id = acl.AGREEMENT_ID
                                            AND ar.AR_TYPE = 4
                                        WHERE
                                            acl.TEXT IN ('Cancelled by payer')) acl
                                ON
                                    acl.CUSTOMERCENTER = dms.PERSON_CENTER
                                    AND acl.CUSTOMERID = dms.PERSON_ID
                                    AND acl.rnk = 1
                                    AND acl.ACL_ENTRY_TIME <= scStop.CHANGE_TIME
                                    AND acl.ACL_ENTRY_TIME >= scStop.CHANGE_TIME - 1000*60*60*24*30 -- max time  between agreement cancellation and sub stop date
                                WHERE
                                    cp.center IN ($$scope$$)
                                    AND dms.ENTRY_STOP_TIME IS NULL
                                    AND DMS.CHANGE_DATE <= params.C_STOP_DATE
                                    --AND CP.EXTERNAL_ID = '4042513'
                                GROUP BY
                                    cp.EXTERNAL_ID,
                                    p.center ,
                                    p.id ,
                                    --   longtodateC(scStop.CHANGE_TIME, cp.center) AS CHANGE_DATE,
                                    dms.change_date,
                                    dms.ENTRY_START_TIME,
                                    cp.BIRTHDATE,
                                    cp.CENTER,
                                    cp.ID,
                                    cp.PERSONTYPE,
                                    cp.SEX,
                                    dms.MEMBER_NUMBER_DELTA,
                                    dms.CHANGE) dms
                        GROUP BY
                            EXTERNAL_ID,
                            CENTER,
                            ID,
                            BIRTHDATE,
                            SEX,
                            PERSONTYPE) dms
                JOIN
                    persons p
                ON
                    p.TRANSFERS_CURRENT_PRS_CENTER = dms."PERSON_KEY_CENTER"
                    AND p.TRANSFERS_CURRENT_PRS_ID = dms."PERSON_KEY_ID"
                LEFT JOIN
                    CHECKINS c
                ON
                    c.PERSON_CENTER = p.center
                    AND c.PERSON_ID = p.id
                    AND c.CHECKIN_TIME < STOP_TIME
                LEFT JOIN
                    (
                        SELECT
                            par.PARTICIPANT_CENTER,
                            par.PARTICIPANT_ID,
                            par.STATE,
                            par.CANCELATION_REASON,
                            par.center||'par'||par.id AS par_id,
                            b.STARTTIME
                        FROM
                            PUREGYM.PARTICIPATIONS par
                        JOIN
                            bookings b
                        ON
                            b.center = par.BOOKING_CENTER
                            AND b.id = par.BOOKING_ID) par
                ON
                    par.STARTTIME BETWEEN STOP_TIME - (12*7*1000*60*60*24) AND $$B_STOP$$ + 1000*60*60*24*30 -- count future participations for 1 month after leaving
                    AND par.PARTICIPANT_CENTER = p.center
                    AND par.PARTICIPANT_ID = p.ID
                WHERE
                    "MEMBER_AT_B_START" =1 -- Exclude members that were not 'Member' at the start of the Behaviour period
                    AND "MEMBER_AT_B_STOP"=1 -- Exclude members that finished the Behaviour period as 'ExMember'
                    AND "MEMBER_AT_C_STOP"=0 -- Exclude members that finished the Churn period as 'ExMember'
            ) pivot ( COUNT(DISTINCT c_id) FOR WEEK_NO IN ( 'WEEK1' WEEK1,
                                                           'WEEK2' WEEK2,
                                                           'WEEK3' WEEK3,
                                                           'WEEK4' WEEK4,
                                                           'WEEK5' WEEK5,
                                                           'WEEK6' WEEK6,
                                                           'WEEK7' WEEK7,
                                                           'WEEK8' WEEK8,
                                                           'WEEK9' WEEK9,
                                                           'WEEK10' WEEK10,
                                                           'WEEK11' WEEK11,
                                                           'WEEK12' WEEK12 )))dms
LEFT JOIN
    (
        SELECT
            "PERSON_ID",
            ROUND(SUM (period_price)) AS "SUB_PERIOD_PRICE_TOTAL"
        FROM
            (
                SELECT
                    cp.EXTERNAL_ID AS "PERSON_ID",
                    spp.center,
                    spp.id,
                    spp.SUBID,
                    SUM(NVL(il.TOTAL_AMOUNT,0) / (SPP.TO_DATE-SPP.FROM_DATE +1)) -- daily price for periocd
                    * SUM(
                        CASE
                            WHEN SPP.TO_DATE > params.B_STOP_DATE
                            THEN params.B_STOP_DATE
                            ELSE SPP.TO_DATE
                        END -
                        CASE
                            WHEN SPP.FROM_DATE < params.B_STOP_DATE - (12*7)
                            THEN params.B_STOP_DATE - (12*7)
                            ELSE SPP.FROM_DATE
                        END) -- number of days in the period
                    AS period_price--Price Per Day
                    --   * ($$B_STOP$$-$$B_STOP$$  - (12*7)) AS "SUB_PRICE_TOTAL"
                FROM
                    params,
                    SUBSCRIPTIONPERIODPARTS spp
                LEFT JOIN
                    SPP_INVOICELINES_LINK sppl
                ON
                    sppl.PERIOD_CENTER = spp.CENTER
                    AND sppl.PERIOD_ID = spp.id
                    AND sppl.PERIOD_SUBID = spp.SUBID
                LEFT JOIN
                    INVOICELINES il
                ON
                    il.center = sppl.INVOICELINE_CENTER
                    AND il.id = sppl.INVOICELINE_ID
                    AND il.SUBID = sppl.INVOICELINE_SUBID
                JOIN
                    SUBSCRIPTIONS SUB
                ON
                    SUB.CENTER = SPP.CENTER
                    AND SUB.id = SPP.id
                JOIN
                    PERSONS p
                ON
                    p.center = sub.OWNER_CENTER
                    AND p.id = sub.OWNER_ID
                JOIN
                    PERSONS cp
                ON
                    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.center = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id= sub.SUBSCRIPTIONTYPE_ID
                WHERE
                    SPP.TO_DATE > params.B_STOP_DATE - (12*7)
                    AND SPP.FROM_DATE < params.B_STOP_DATE
                    AND (
                        SPP.CANCELLATION_TIME = 0
                        OR SPP.CANCELLATION_TIME IS NULL)
                    AND st.ST_TYPE = 1
                    AND spp.center IN($$scope$$)
                GROUP BY
                    cp.EXTERNAL_ID,
                    spp.center,
                    spp.id,
                    spp.SUBID)
        GROUP BY
            "PERSON_ID") sub_period
ON
    sub_period."PERSON_ID" = dms."PERSON_ID"
    /*LEFT JOIN
    (
    SELECT
    p.EXTERNAL_ID,
    pet.LAST_EDIT_TIME,
    DECODE(pet.TXTVALUE,NULL,0,1) AS "JOINED_MOBILE_APP"
    FROM
    persons p
    LEFT JOIN
    PERSON_EXT_ATTRS pet
    ON
    pet.PERSONCENTER = p.center
    AND pet.PERSONID = p.id
    AND pet.NAME = '_eClub_HasLoggedInMemberMobileApp'
    AND pet.TXTVALUE = 'true' ) ma
    ON
    ma.EXTERNAL_ID = dms."PERSON_ID"
    AND ma.LAST_EDIT_TIME < (to_date(dms."STOP_DATE") - to_date('1970-01-01','yyyy-MM-dd')) *1000*60*60*24*/
WHERE
    "MEMBER_AT_B_START" =1 -- Exclude members that were not 'Member' at the start of the Behaviour period
    AND"MEMBER_AT_B_STOP"=1 -- Exclude members that finished the Behaviour period as 'ExMember'
    AND"MEMBER_AT_C_STOP"=0 -- Exclude members that finished the Churn period as 'ExMember'
    --AND dms."PERSON_TYPE" NOT IN (4,2) -- Exclude CORPORATE and STAFF type persons
    AND dms."PERSON_TYPE" = 0
    AND FLOOR((params.B_STOP_DATE - "BIRTHDATE")/365) BETWEEN 16 AND 100 -- Exclude members that are over 100 years old
    AND"VISITS_COUNT" > 0
    AND dms.MIGRATION_DATE IS NULL
    AND"CHANGE_IN_CHURN_DURATION" = 0