-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	 c.id "ClubID",
     c.SHORTNAME "Held At",
	 per.Center ||'p'|| per.id "Membership Number",
	 per.firstname "Member First Name",
	 ins.FULLNAME "Trainer",	
	 CASE
    WHEN mpr.CACHED_PRODUCTNAME = 'PT - Kickstart Promo' THEN 'PT Level 1'
WHEN mpr.CACHED_PRODUCTNAME = 'PT - Staff' THEN 'PT Level 1'
WHEN mpr.CACHED_PRODUCTNAME = 'PT (No Level)' THEN 'PT Level 1'
WHEN mpr.CACHED_PRODUCTNAME = 'PT - Kickstart Promo' THEN 'PT Level 1'
WHEN mpr.CACHED_PRODUCTNAME = 'PT - Full Throttle Promo' THEN 'PT Level 1'
    ELSE act.NAME
  END "Activity Name",
     mpr.CACHED_PRODUCTNAME "Clip Card Used",	 
     CASE WHEN par.STATE = 'PARTICIPATION' THEN 'Yes'
		  WHEN par.STATE = 'CANCELLED' THEN 'No'
		  ELSE par.STATE END AS "Attended",        
	 longtodateC(bk.STARTTIME,bk.center) "Date of PT Session", 
	 TO_CHAR(longtodateC(bk.STARTTIME,bk.center), 'HH24:MI') "Start Time",	 
	 bk.center || 'bk' || bk.ID "Booking ID", 		 			 
     ins.Center ||'p'|| ins.id "Exerp Staff ID",
	CAST(staffID.txtvalue AS INTEGER) AS "Trainer ID"
     --su_p.FULLNAME EMPLOYEE_LOGIN_name
     
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
 LEFT JOIN
         PERSON_EXT_Attrs ptlvl
         ON ins.center = ptlvl.Personcenter
         AND ins.id = ptlvl.PERSONID
		 AND ptlvl.name ='PTLevel'
 LEFT JOIN
         PERSON_EXT_Attrs staffID
         ON ins.center = staffID.Personcenter
         AND ins.id = staffID.PERSONID
		 AND staffID.name ='_eClub_StaffExternalId'
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
     actgr.NAME IN ('Personal Training','Group Personal Training', 'Coaching','Group PT')
     AND bk.center IN (:scope)
     AND bk.STARTTIME >= (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - INTERVAL '60 days')) * 1000)::bigint
     and st.STATE = 'ACTIVE'
     AND bk.STARTTIME < (EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000)::bigint
	AND act.NAME not in ('Admin','Meeting')
 /*    AND par.STATE = 'PARTICIPATION'*/
 GROUP BY
	
     par.SHOWUP_USING_CARD,
	c.id,
     c.NAME,
	  ins.Center ||'p'|| ins.id,
	  per.external_id,
	  FLOOR(EXTRACT(YEAR FROM AGE(CURRENT_DATE, per.BIRTHDATE))),
     ins.FULLNAME,
     ptlvl.txtvalue,
     per.Center,
     per.id,
     per.FULLNAME,
     bk.STARTTIME,
     bk.STARTTIME,
     bk.center,
	 bk.id,
     bk.STOPTIME,
     act.NAME,
     par.SHOWUP_TIME,
     su_p.FULLNAME,
     pg.GRANTER_SERVICE,
     mpr.CACHED_PRODUCTNAME,
     par.STATE,
     par.CANCELATION_REASON,
     par.CANCELATION_TIME,
     par.CENTER,
     staffID.txtvalue
