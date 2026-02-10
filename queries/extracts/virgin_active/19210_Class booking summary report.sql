-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     PARAMS AS
     (
         SELECT
             datetolongTZ(TO_CHAR(startdate, 'YYYY-MM-DD HH24:MI'), 'Europe/London' )  AS STARTTIME ,
             datetolongTZ(TO_CHAR(endtdate, 'YYYY-MM-DD HH24:MI'), 'Europe/London') AS ENDTIME
         FROM
             (
                 SELECT
                    $$longDateFrom$$ AS startdate,
                     $$longDateTo$$ AS endtdate
                 ) t
     )
 SELECT /*+ index(par IDX_PART_BK_STATE) */
         date_trunc('day',longtodateTZ(par.CREATION_TIME, 'Europe/London')) AS "Date",
         CASE bo.ActivityType WHEN 2 THEN 'Class' WHEN 3 THEN 'Resource booking' WHEN 4 THEN 'Staff booking' WHEN 5 THEN 'Meeting' WHEN 6 THEN 'Staff availability' ELSE 'Unkown' END AS "Activity Type",
         bo.Category AS "Category",
         CASE par.USER_INTERFACE_TYPE WHEN 1 THEN 'STAFF' WHEN 2 THEN 'WEB' WHEN 3 THEN 'KIOSK' WHEN 4 THEN 'SCRIPT' WHEN 5 THEN 'API' WHEN 6 THEN 'MOBILE API' WHEN 0 THEN 'OTHER' END AS "Interface",
         count(*) AS "Number of bookings"
 FROM PARAMS,
         PARTICIPATIONS par
 JOIN
 (
         SELECT /*+ index(bo IDX_BOOKINGS_ACTIVITY)*/
                 bo.CENTER,
                 bo.ID,
                ac.ACTIVITY_TYPE AS ActivityType,
                 (CASE
                         WHEN acg.NAME IN ('Body Conditioning','Cardio','Cardio Fitness','Cycle','Dance','Fast Class','GRID','High Intensity Training',
                                           'Other','Running','Sleep Pods','Strength','Waterbased','Yoga/ Pilates') THEN
                                 'GroupEx'
                          WHEN acg.NAME IN ('Personal Training') THEN
                                 'PT'
                         WHEN acg.NAME IN ('Adult groups','Adult Tennis Coaching Programme','Badminton','Individual play',
                                           'Individual Play tennis','Junior groups','Outdoor tennis','Pay and play','Private lessons') THEN
                                 'Racquets'
                         WHEN acg.NAME IN ('Club Induction','Fitness') THEN
                                 'Fitness'
                         WHEN acg.NAME IN ('Altitude Induction') THEN
                                 'Altitude'
                 END) AS Category
         FROM
                 BOOKINGS bo
         JOIN ACTIVITY ac
                 ON ac.ID = bo.ACTIVITY
         JOIN ACTIVITY_GROUP acg
                 ON acg.ID = ac.ACTIVITY_GROUP_ID
                 AND acg.NAME IN ('Adult groups','Adult Tennis Coaching Programme','Altitude Induction','Badminton','Body Conditioning',
                                  'Cardio','Cardio Fitness','Club Induction','Cycle','Dance','Fast Class','Fitness','GRID','High Intensity Training',
                                  'Individual play','Individual Play tennis','Junior groups','Other','Outdoor tennis','Pay and play','Personal Training',
                                  'Private lessons','Running','Sleep Pods','Strength','Waterbased','Yoga/ Pilates')
 ) bo
         ON  par.BOOKING_ID = bo.ID
         AND par.BOOKING_CENTER = bo.CENTER
 WHERE
     par.CENTER in ($$scope$$)
     AND par.CREATION_TIME > PARAMS.STARTTIME
     AND par.CREATION_TIME < PARAMS.ENDTIME + (24*60*60*1000)
     AND ((:activityType = 0) or (:activityType = bo.ActivityType))
 GROUP BY
         date_trunc('day',longtodateTZ(par.CREATION_TIME, 'Europe/London')),
         bo.ActivityType,
         bo.Category,
         par.USER_INTERFACE_TYPE
 ORDER BY 1
