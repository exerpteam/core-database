-- The extract is extracted from Exerp on 2026-02-08
-- Excludes No Privilege
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
        p2.external_id AS "Staff member external ID"
        ,p2.firstname AS "Staff first name"
        ,p2.lastname AS "Staff Last name"
        ,b.name AS "Area name"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'DD/MM/YYYY') AS "Date" 
        ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI:SS') AS "Start Time" 
        ,0 AS "Meal Break"
        ,TO_CHAR(longtodateC(b.stoptime,b.center),'HH24:MI:SS') AS "End Time"
        ,p.fullname AS "Member Name"
        ,p.center||'p'||p.id AS "Member ID"
        ,part.state AS "Comment (Optional)"            
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
        AND ac.id in (803,2,601,3401,3,9003,24608,24207,3,23445,24405,23449,23861,33208,33413,45209,9404,15406,27401,38615,38819,45208,52804,55003,56403,58604,59407,59409,59410,59605,59606,59803,8802,9405,9406,21615,21616,21812,22212,23413,26211,26417,26418,26618,59401,59402,59403,59404,59405,59602,59801,59802)
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
        centers c2
        ON b.center = c2.id        
WHERE 
       b.center in (:Scope)
       AND b.starttime BETWEEN params.FromDate AND params.ToDate
