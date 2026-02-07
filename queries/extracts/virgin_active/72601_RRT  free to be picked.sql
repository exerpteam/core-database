WITH params AS MATERIALIZED
(
        SELECT
                :fromDate AS fromDate,
                :toDate + (1000*60*60*24) AS toDate,
                c.id AS center_id,
                c.name AS club
        FROM virginactive.centers c
        WHERE
                c.country = 'GB'
                AND c.id IN (:scope)
)
SELECT
        params.club,
        ins.Center ||'p'|| ins.id "PT Membership Number",--RG 31.01.22 - added this for Georgina to pull in the PT memberhip number
        ins.FULLNAME "PT Name",
        per.Center ||'p'|| per.id "Membership Number",
        per.external_id as "External_ID", --RG added this and the two below for James Shilling on 06.03.23
        floor(months_between(TRUNC(CURRENT_TIMESTAMP),per.BIRTHDATE) / 12) as "Age",
        per.sex as "Gender",		 
        per.FULLNAME "Client Name",
        par.STATE PARTICIPATION_STATE,
        par.CANCELATION_REASON,
        TO_CHAR(longtodateC(par.CANCELATION_TIME,bk.CENTER),'YYYY-MM-DD HH24:MI') CANCELLATION_TIME,
        TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'YYYY-MM-DD') "Date of PT Session",
        TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'HH24:MI') "Start Time",
        TO_CHAR(longtodateC(bk.STOPTIME,bk.center), 'HH24:MI') "End Time",
        act.NAME "PT Session Type",
        TO_CHAR(longtodateC(par.SHOWUP_TIME,bk.center), 'HH24:MI') "Swipe to Attend Time",
        --longToDateC(MAX(cin.CHECKIN_TIME),par.CENTER) LATEST_SWIPE_WITH_CARD,
        par.SHOWUP_USING_CARD SWIPE_VALIDATED,
        su_p.FULLNAME EMPLOYEE_LOGIN_name,
        mpr.CACHED_PRODUCTNAME package_name
FROM virginactive.bookings bk
JOIN params params
        ON params.center_id = bk.center
JOIN virginactive.activity act
        ON bk.activity = act.id
JOIN virginactive.activity_group actgr
        ON act.activity_group_id = actgr.id
JOIN virginactive.activity_staff_configurations staffconfig
        ON staffconfig.activity_id = act.id
JOIN virginactive.staff_groups stfg
        ON stfg.id = staffconfig.staff_group_id
LEFT JOIN virginactive.participations par
        ON par.BOOKING_CENTER = bk.CENTER AND par.BOOKING_ID = bk.ID
LEFT JOIN STAFF_USAGE st
        ON bk.center = st.BOOKING_CENTER AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins
        ON st.PERSON_CENTER = ins.CENTER AND st.PERSON_ID = ins.ID
JOIN PERSONS per
        ON par.PARTICIPANT_CENTER = per.CENTER AND par.PARTICIPANT_ID = per.ID
LEFT JOIN PERSON_STAFF_GROUPS psg
        ON psg.PERSON_CENTER = ins.CENTER AND psg.PERSON_ID = ins.ID
        AND psg.STAFF_GROUP_ID = stfg.ID AND psg.SCOPE_TYPE = 'C'
        AND psg.SCOPE_ID = bk.CENTER
LEFT JOIN PERSONS su_p
        ON su_p.CENTER = par.SHOWUP_BY_CENTER AND su_p.ID = par.SHOWUP_BY_ID
LEFT JOIN PRIVILEGE_USAGES pu
        ON pu.TARGET_SERVICE IN ('Participation') AND pu.TARGET_CENTER = par.CENTER
        AND pu.TARGET_ID = par.ID
LEFT JOIN PRIVILEGE_GRANTS pg
        ON pg.ID = pu.GRANT_ID
LEFT JOIN MASTERPRODUCTREGISTER mpr
        ON mpr.ID = pg.GRANTER_ID AND pg.GRANTER_SERVICE IN ('GlobalCard','GlobalSubscription','Addon')
/*LEFT JOIN CHECKINS cin
        ON cin.PERSON_CENTER = per.CENTER AND cin.PERSON_ID = per.ID
        AND cin.CHECKIN_CENTER = par.CENTER AND cin.CHECKIN_TIME <= par.SHOWUP_TIME
        AND cin.CARD_CHECKED_IN IS NOT NULL*/
WHERE
     actgr.NAME IN ('Personal Training','Group Personal Training')
     --AND bk.center IN (:scope)
     AND bk.STARTTIME >= params.fromDate 
     AND st.STATE = 'ACTIVE'
     AND bk.STARTTIME < params.toDate
GROUP BY    
        par.SHOWUP_USING_CARD,
        params.club,
        ins.Center,
        ins.id,
        per.external_id,
        per.BIRTHDATE,
        per.sex,
        ins.FULLNAME,
        per.Center,
        per.id,
        per.FULLNAME,
        bk.STARTTIME,
        bk.STARTTIME,
        bk.center,
        bk.STOPTIME,
        act.NAME,
        par.SHOWUP_TIME,
        su_p.FULLNAME,
        pg.GRANTER_SERVICE,
        mpr.CACHED_PRODUCTNAME,
        par.STATE,
        par.CANCELATION_REASON,
        par.CANCELATION_TIME,
        par.CENTER
