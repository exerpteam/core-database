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
        TO_CHAR(longtodateC(a.START_TIME,c.id),'YYYY-MM-DD') AS "Start Date", 
        TO_CHAR(longtodateC(a.START_TIME,c.id),'HH24:MI') AS "Start Time", 
        p.FULLNAME AS "Name Surname", 
        p.CENTER || 'p' || p.ID AS "Member ID", 
        c.NAME AS "Center Name",
        r.name
FROM ATTENDS a
JOIN 
        CENTERS c
        ON a.CENTER = c.ID
JOIN
        PERSONS p
        ON p.CENTER = a.PERSON_CENTER AND p.ID = a.PERSON_ID
JOIN
        BOOKING_RESOURCES r
        ON r.CENTER = a.BOOKING_RESOURCE_CENTER AND r.ID = a.BOOKING_RESOURCE_ID AND r.name in ('Start Work Shift','End Work Shift')    
JOIN params 
        ON params.CENTER_ID = a.center        
WHERE 
        c.ID in (:scope) 