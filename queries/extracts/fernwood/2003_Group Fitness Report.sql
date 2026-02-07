WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT
        TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD HH24:MI') AS "Start Time"
        ,TO_CHAR(longtodateC(b.stoptime,b.center),'YYYY-MM-DD HH24:MI') AS "End Time"
        ,ac.name AS "Class Name"
        ,b.state AS "Status"
        ,c.name AS "Club"
        ,booked.booked AS "Number of booked Members"
        ,p.participants AS "Number of Attended Members"       
        ,b.class_capacity AS "Class Capacity"
        ,CAST(p.participants AS numeric)/ CAST(b.class_capacity AS numeric) * 100 as "% of capacity"
        ,ins.fullname AS "Instructor"
FROM 
        fernwood.bookings b
LEFT JOIN 
        (
        SELECT 
                booking_center
                ,booking_id
                ,count(*) as booked 
        FROM 
                fernwood.participations
        WHERE 
                (cancelation_reason not in ('USER','BOOKING','CENTER','API') OR cancelation_reason IS NULL)  
        GROUP BY  
                booking_center,booking_id
        )booked 
                ON booked.booking_center = b.center 
                and booked.booking_id = b.id 
LEFT JOIN 
        (
        SELECT 
                booking_center
                ,booking_id
                ,count(*) as participants 
        FROM 
                fernwood.participations
        WHERE 
                state = 'PARTICIPATION' 
        GROUP BY  
                booking_center,booking_id
        )p 
                ON p.booking_center = b.center 
                and p.booking_id = b.id                                 
JOIN 
        fernwood.centers c 
                ON c.ID = b.center
JOIN 
        fernwood.activity ac 
                ON b.activity = ac.id
JOIN 
        params 
                ON params.CENTER_ID = b.center  
JOIN 
        fernwood.staff_usage su 
                ON su.booking_center = b.center 
                AND su.booking_id = b.id 
                AND su.cancellation_time IS NULL
JOIN 
        fernwood.persons ins 
                ON ins.center = su.person_center 
                AND ins.id = su.person_id 
WHERE
      
        b.starttime BETWEEN params.FromDate AND params.ToDate
        AND 
        ac.activity_group_id not in (17,1201,801,10,401,402,1401,1601,2601,2401)
        AND 
        b.state != 'CANCELLED'
        AND 
        b.center in (:Scope)
		AND ac.name != 'Staff Break 30 Mins'
ORDER BY 
        b.starttime