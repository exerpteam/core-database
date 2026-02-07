WITH
  params AS
  (
      SELECT
          /*+ materialize */
          dateToLongC(getcentertime(c.id), c.id) AS CurrentDate,
          dateToLongC((to_char((to_date((getcentertime(c.id)), 'YYYY-MM-DD')-7 ),'YYYY-MM-DD HH24:MI:SS')), c.id) AS CutDate, 
          c.id AS CENTER_ID
      FROM
          centers c
  )
SELECT DISTINCT 
        TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD HH24:MI:SS') AS "Start Time" 
        ,TO_CHAR(longtodateC(b.stoptime,b.center),'YYYY-MM-DD HH24:MI:SS') AS "End Time"
        ,b.name AS "Area"
        ,c2.shortname AS "Location (Optional)"
        ,0 AS "Meal Break"
        ,p2.fullname AS "Employee (Optional)"
        ,part.state AS "Comment (Optional)"
        ,p.fullname AS "Member Name"
        ,p.center||'p'||p.id AS "Person ID"
        ,part.Cancelation_Reason        
FROM 
        participations part
JOIN 
        persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN 
        bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN 
        params 
        ON params.CENTER_ID = part.booking_center
JOIN 
        activity ac
        ON b.activity = ac.id
        AND ac.id in (803,2,601,3401,8020,9003)
JOIN 
        STAFF_USAGE su
        ON su.BOOKING_CENTER = b.center
        AND su.BOOKING_ID = b.id
        AND su.state = 'ACTIVE'
LEFT JOIN 
        persons p2
        ON p2.CENTER = su.PERSON_CENTER
        AND p2.id = su.PERSON_ID         
JOIN
        fernwood.centers c2
        ON b.center = c2.id  
JOIN
        fernwood.centers c
        ON c.id = p.center               
WHERE
        b.center in (:Scope)
        AND
        b.starttime BETWEEN params.CutDate AND params.CurrentDate