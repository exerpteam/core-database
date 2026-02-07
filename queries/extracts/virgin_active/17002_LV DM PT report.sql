SELECT distinct
    c.NAME Club,
   -- ins.FULLNAME "PT Name",
            per.Center ||'p'|| per.id "Membership Number",
    per.FULLNAME "Client Name"
   -- par.STATE PARTICIPATION_STATE,
   -- par.CANCELATION_REASON,
      --      TO_CHAR(longtodateC(par.CANCELATION_TIME,bk.CENTER),'YYYY-MM-DD HH24:MI') CANCELLATION_TIME,
  --  TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'YYYY-MM-DD') "Date of PT Session",
  --  TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'HH24:MI') "Start Time",
  --  TO_CHAR(longtodateC(bk.STOPTIME,bk.center), 'HH24:MI') "End Time",
  --  act.NAME "PT Session Type",
  --  TO_CHAR(longtodateC(par.SHOWUP_TIME,bk.center), 'HH24:MI') "Swipe to Attend Time",
--    MAX(longToDateC(cin.CHECKIN_TIME,par.CENTER)) LATEST_SWIPE_WITH_CARD,
   --         par.SHOWUP_USING_CARD SWIPE_VALIDATED,
 --   /*su_emp.CENTER || 'emp' || su_emp.ID EMPLOYEE_LOGIN_ID,*/
 --   su_p.FULLNAME EMPLOYEE_LOGIN_name,
   -- /* pg.GRANTER_SERVICE package_type, */
  --  mpr.CACHED_PRODUCTNAME package_name
FROM
    BOOKINGS bk
JOIN CENTERS c
ON
    c.id = bk.CENTER
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
JOIN ACTIVITY_GROUP actgr
ON
    act.ACTIVITY_GROUP_ID = actgr.ID
JOIN ACTIVITY_STAFF_CONFIGURATIONS staffconfig
ON
    staffconfig.ACTIVITY_ID = act.ID
JOIN STAFF_GROUPS stfg
ON
    stfg.ID = staffconfig.STAFF_GROUP_ID
LEFT JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
LEFT JOIN STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
JOIN PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID
LEFT JOIN PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER = ins.CENTER
    AND psg.PERSON_ID = ins.ID
    AND psg.STAFF_GROUP_ID = stfg.ID
    AND psg.SCOPE_TYPE = 'C'
    AND psg.SCOPE_ID = bk.CENTER
 
LEFT JOIN
    PERSONS su_p
ON
    su_p.CENTER = par.SHOWUP_BY_CENTER
    AND su_p.ID = par.SHOWUP_BY_ID
LEFT JOIN PRIVILEGE_USAGES pu
ON
    pu.TARGET_SERVICE IN ('Participation')
    AND pu.TARGET_CENTER = par.CENTER
    AND pu.TARGET_ID = par.ID
LEFT JOIN PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
LEFT JOIN MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE IN ('GlobalCard','GlobalSubscription','Addon')
LEFT JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = per.CENTER
    AND cin.PERSON_ID = per.ID
    AND cin.CHECKIN_CENTER = par.CENTER
    AND cin.CHECKIN_TIME <= par.SHOWUP_TIME
    AND cin.CARD_CHECKED_IN IS NOT NULL
WHERE
    --    bk.center >0
    --    AND longtodateC(bk.STARTTIME,bk.center) >= TO_DATE('2013-05-01', 'YYYY-MM-DD')
    --    AND longtodateC(bk.STARTTIME,bk.center) < TO_DATE('2015-05-31', 'YYYY-MM-DD') + 1
    actgr.NAME = 'Personal Training'
    AND bk.center IN
(
401,
443)

    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + (1000*60*60*24)
/*    AND par.STATE = 'PARTICIPATION'*/
GROUP BY
            par.SHOWUP_USING_CARD,
    c.NAME ,
    ins.FULLNAME ,
            per.Center ||'p'|| per.id,
    per.FULLNAME ,
    TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'YYYY-MM-DD'),
    TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'HH24:MI') ,
    TO_CHAR(longtodateC(bk.STOPTIME,bk.center), 'HH24:MI') ,
    act.NAME ,
    TO_CHAR(longtodateC(par.SHOWUP_TIME,bk.center), 'HH24:MI') ,
    su_p.FULLNAME ,
    pg.GRANTER_SERVICE ,
    mpr.CACHED_PRODUCTNAME,
        par.STATE,
    par.CANCELATION_REASON,
TO_CHAR(longtodateC(par.CANCELATION_TIME,bk.CENTER),'YYYY-MM-DD HH24:MI')
