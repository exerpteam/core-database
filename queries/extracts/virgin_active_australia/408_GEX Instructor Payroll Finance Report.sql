-- This is the version from 2026-02-05
-- GEX Instructor Payroll Finance Report Gladstone Equivalent
WITH params AS (
    SELECT
    CASE 
        WHEN $$reporting_period$$ = 'F' THEN
            (EXTRACT(EPOCH FROM ((date_trunc('week', CURRENT_DATE) - INTERVAL '15 days') AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint
        WHEN $$reporting_period$$ = 'M' THEN
            (EXTRACT(EPOCH FROM ((date_trunc('month', CURRENT_DATE) - INTERVAL '1 month') AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint
    END AS PeriodStart,

    CASE 
        WHEN $$reporting_period$$ = 'F' THEN
            (EXTRACT(EPOCH FROM ((date_trunc('week', CURRENT_DATE) - INTERVAL '1 day') AT TIME ZONE 'Australia/Sydney')) * 1000)::bigint
        WHEN $$reporting_period$$ = 'M' THEN
            ((EXTRACT(EPOCH FROM ((date_trunc('month', CURRENT_DATE) - INTERVAL '1 day') AT TIME ZONE 'Australia/Sydney')) + 86400 - 1) * 1000)::bigint
    END AS PeriodEnd
)

 SELECT
     c.ID AS "Club ID",
     c.SHORTNAME                                                AS "Club Name",
	 staff.center || 'p' || staff.ID                            AS "Instructor ID",
CAST(staffID.txtvalue AS INTEGER) AS "Payroll ID",
	 staff.FULLNAME                                             AS "Instructor Name",
	 bo.center || 'bk' || bo.ID                                 AS "BookingId",
	 longtodateC(bo.STARTTIME,bo.center) AS "Class Date",
	 TO_CHAR(longtodateC(bo.STARTTIME,bo.center), 'HH24:MI') "Class Time",
     bo.NAME                                                        AS "Class Name",
     ag.name                                                        AS "Class Pay Category",
         
     
        -- PES.TXTVALUE       AS "Instructor Status",
case when ag.name = 'Cycle' then CycleIns.txtvalue
	 when ag.name = 'Grid' then GridIns.txtvalue
     when ag.name = 'Reformer' then ReformerIns.txtvalue
     when ag.name = 'Yoga' then YogaIns.txtvalue
	 when ag.name = 'Boxing' then BoxingIns.txtvalue
	 when ag.name = 'Barre' then BarreIns.txtvalue
	 when ag.name = 'Bottoms Up' then BottomsUpIns.txtvalue
	 when ag.name = 'Lift Club' then LiftClubIns.txtvalue
	 when ag.name = 'Licensed' then LicensedIns.txtvalue
	 when ag.name = 'Unlicensed' then UnLicensedIns.txtvalue
else null end as "Instructor Pay Category",
	 ROUND(EXTRACT(EPOCH FROM (longtodateC(bo.STOPTIME, bo.center) - longtodateC(bo.STARTTIME, bo.center))) / 60) AS "Class Length"
     
 FROM
     BOOKINGS bo
 CROSS JOIN
     params
 JOIN
     STAFF_USAGE su
 ON
     bo.CENTER = su.BOOKING_CENTER
     AND bo.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
 JOIN
     BOOKING_RESOURCE_USAGE bru
 ON
     bo.ID = bru.BOOKING_ID
     AND bo.CENTER = bru.BOOKING_CENTER
         AND bru.STATE = 'ACTIVE'
 JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID
 LEFT JOIN
         PERSON_EXT_Attrs PES
         ON staff.center = PES.Personcenter
         AND staff.id = PES.PERSONID
         AND PES.name = 'InstructorStatus'
LEFT JOIN
         PERSON_EXT_Attrs YogaIns
         ON staff.center = YogaIns.Personcenter
         AND staff.id = YogaIns.PERSONID
		 AND YogaIns.name ='InstructorLevelYoga'
LEFT JOIN
         PERSON_EXT_Attrs BoxingIns
         ON staff.center = BoxingIns.Personcenter
         AND staff.id = BoxingIns.PERSONID
		 AND BoxingIns.name ='InstructorLevelBoxing'
 LEFT JOIN
         PERSON_EXT_Attrs GridIns
         ON staff.center = GridIns.Personcenter
         AND staff.id = GridIns.PERSONID
		 AND GridIns.name ='IntructorLevelGrid'
LEFT JOIN
         PERSON_EXT_Attrs CycleIns
         ON staff.center = CycleIns.Personcenter
         AND staff.id = CycleIns.PERSONID
		 AND CycleIns.name ='InstructorLevelCycle'
LEFT JOIN
         PERSON_EXT_Attrs ReformerIns
         ON staff.center = ReformerIns.Personcenter
         AND staff.id = ReformerIns.PERSONID
		 AND ReformerIns.name ='InstructorLevelReformer'
LEFT JOIN
         PERSON_EXT_Attrs BarreIns
         ON staff.center = BarreIns.Personcenter
         AND staff.id = BarreIns.PERSONID
		 AND BarreIns.name ='InstructorLevelBarre'
LEFT JOIN
         PERSON_EXT_Attrs LiftClubIns
         ON staff.center = LiftClubIns.Personcenter
         AND staff.id = LiftClubIns.PERSONID
		 AND LiftClubIns.name ='InstructorLevelLiftClub'
LEFT JOIN
         PERSON_EXT_Attrs BottomsUpIns
         ON staff.center = BottomsUpIns.Personcenter
         AND staff.id = BottomsUpIns.PERSONID
		 AND BottomsUpIns.name ='InstructorLevelBottomsUp'
LEFT JOIN
         PERSON_EXT_Attrs LicensedIns
         ON staff.center = LicensedIns.Personcenter
         AND staff.id = LicensedIns.PERSONID
		 AND LicensedIns.name ='InstructorLevelLicensed'
LEFT JOIN
         PERSON_EXT_Attrs UnLicensedIns
         ON staff.center = UnLicensedIns.Personcenter
         AND staff.id = UnLicensedIns.PERSONID
		 AND UnLicensedIns.name ='InstructorLevelUnlicensed'
LEFT JOIN
         PERSON_EXT_Attrs staffID
         ON staff.center = staffID.Personcenter
         AND staff.id = staffID.PERSONID
		 AND staffID.name ='_eClub_StaffExternalId'		 
 JOIN
     BOOKING_RESOURCES br
 ON
     br.CENTER = bru.BOOKING_RESOURCE_CENTER
     AND br.ID = bru.BOOKING_RESOURCE_ID
 JOIN
     CENTERS c
 ON
     c.ID = bo.CENTER
 JOIN
     ACTIVITY ac
 ON
     ac.ID = bo.ACTIVITY
     /* Activity type 'Class' only*/
     AND ac.activity_type = 2
 JOIN
     ACTIVITY_GROUP ag
 ON
     ag.ID = ac.activity_group_id
 JOIN
     (
         SELECT
             SUM( 1 )AS total,
             SUM(
                 CASE
                     WHEN pa.state = 'PARTICIPATION'
                     THEN 1
                     ELSE 0
                 END )AS total_showup,
             SUM(
                 CASE
                     WHEN pa.state = 'PARTICIPATION' AND pa.participant_center is null
                     THEN 1
                     ELSE 0
                 END )AS total_anonymous,
             SUM(
                 CASE
                     WHEN pa.state = 'BOOKED'
                         AND pa.on_waiting_list = 0
                     THEN 1
                     ELSE 0
                 END)AS total_booked,
             SUM(
                 CASE
                     WHEN pa.state = 'BOOKED'
                         AND pa.on_waiting_list = 1
                     THEN 1
                     WHEN pa.state = 'CANCELLED'
                         AND pa.CANCELATION_REASON = 'NO_SEAT'
                     THEN 1
                     ELSE 0
                 END)AS total_waiting,
             SUM(
                 CASE
                     WHEN pa.state = 'CANCELLED'
                         AND pa.CANCELATION_REASON IN ('CENTER',
                                                       'BOOKING',
                                                       'USER')
                     THEN 1
                     ELSE 0
                 END)AS total_cancel,
             SUM(
                 CASE
                     WHEN pa.state = 'CANCELLED'
                         AND pa.CANCELATION_REASON IN ('NO_SHOW',
                                                       'USER_CANCEL_LATE')
                     THEN 1
                     ELSE 0
                 END)AS total_noshow,
             pa.booking_center,
             pa.booking_id
         FROM
             participations pa
         CROSS JOIN
             params params1
         JOIN
             BOOKINGS bo1
         ON
             pa.booking_center = bo1.center
             AND pa.booking_id = bo1.id
         WHERE
             bo1.CENTER IN ($$scope$$)
             AND bo1.STARTTIME>= params1.PeriodStart
             AND bo1.STARTTIME<= params1.PeriodEnd
             AND bo1.STATE='ACTIVE'
         GROUP BY
             pa.booking_center,
             pa.booking_id )showup_waiting_cancel
 ON
     showup_waiting_cancel.booking_center = bo.center
     AND showup_waiting_cancel.booking_id = bo.id
 WHERE
     (('ALL' IN ($$activity_group$$))
            OR (ag.name like replace($$activity_group$$,'*','%')))
     AND (('ALL' IN ($$class_name$$))
            OR (bo.name like replace($$class_name$$,'*','%')))
     AND (('ALL' IN ($$instructor_name$$))
            OR (staff.FULLNAME  like replace($$instructor_name$$,'*','%')))
     AND bo.STARTTIME>= params.PeriodStart
     AND bo.STARTTIME<= params.PeriodEnd
     AND bo.CENTER IN ($$scope$$)
         AND bo.STATE='ACTIVE'
 ORDER BY
     c.NAME,
     bo.starttime,
     bo.name
