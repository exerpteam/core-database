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
        AND ac.id in (803,2,601,3401,8020,9003,59606,59409,59605,59407)
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
WHERE 
       b.center in (:Scope)
       AND b.starttime BETWEEN params.FromDate AND params.ToDate
