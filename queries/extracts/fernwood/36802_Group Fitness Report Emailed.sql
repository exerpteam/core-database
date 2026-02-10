-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          dateToLongC(TO_CHAR(CURRENT_DATE - 7, 'YYYY-MM-DD HH24:MI:SS'), c.id) AS FromDate,
          dateToLongC(TO_CHAR(CURRENT_DATE + 1, 'YYYY-MM-DD HH24:MI:SS'), c.id) - 1 AS ToDate,
          c.id AS CENTER_ID
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
        bookings b
LEFT JOIN 
        (
        SELECT 
                booking_center
                ,booking_id
                ,count(*) as booked 
        FROM 
                participations
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
                participations
        WHERE 
                state = 'PARTICIPATION' 
        GROUP BY  
                booking_center,booking_id
        )p 
                ON p.booking_center = b.center 
                and p.booking_id = b.id                                 
JOIN 
        centers c 
                ON c.ID = b.center
JOIN 
        activity ac 
                ON b.activity = ac.id
JOIN 
        params 
                ON params.CENTER_ID = b.center  
JOIN 
        staff_usage su 
                ON su.booking_center = b.center 
                AND su.booking_id = b.id 
                AND su.cancellation_time IS NULL
JOIN 
        persons ins 
                ON ins.center = su.person_center 
                AND ins.id = su.person_id 
WHERE
      
        b.starttime BETWEEN params.FromDate AND params.ToDate
        AND 
        ac.activity_group_id not in (201,17,1201,801,10,401,402,1401,1601,2601,2401)
        AND 
        b.state != 'CANCELLED'
        AND 
        b.center in (:Scope)
		AND ac.name != 'Staff Break 30 Mins'
		AND ac.name != 'Complimentary Personal Training Session'
ORDER BY 
        b.starttime