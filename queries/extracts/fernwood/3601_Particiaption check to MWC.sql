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
        c.name
		,b.name AS "Class Name"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Class Date" 
        ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Class Time"
        ,p.center||'p'||p.id AS "Person ID"
        ,p.firstname AS "First Name"
		,p.lastname 
        ,CASE
                WHEN part.user_interface_type = 0 THEN 'OTHER'
                WHEN part.user_interface_type = 1 THEN 'CLIENT'
                WHEN part.user_interface_type = 2 THEN 'WEB'
                WHEN part.user_interface_type = 3 THEN 'KIOSK'
                WHEN part.user_interface_type = 4 THEN 'SCRIPT'
                WHEN part.user_interface_type = 5 THEN 'API'
                WHEN part.user_interface_type = 6 THEN 'MOBILE API'
                ELSE 'UNKNOWN'
        END AS "Booking creation interface"
        ,CASE
                WHEN part.cancelation_interface_type = 0 THEN 'OTHER'
                WHEN part.cancelation_interface_type = 1 THEN 'CLIENT'
                WHEN part.cancelation_interface_type = 2 THEN 'WEB'
                WHEN part.cancelation_interface_type = 3 THEN 'KIOSK'
                WHEN part.cancelation_interface_type = 4 THEN 'SCRIPT'
                WHEN part.cancelation_interface_type = 5 THEN 'API'
                WHEN part.cancelation_interface_type = 6 THEN 'MOBILE API'
                ELSE ''
        END AS "Booking cancellation interface"
        ,part.state AS "Booking Status"         
FROM participations part
JOIN persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN params 
        ON params.CENTER_ID = part.booking_center
JOIN activity ac
        ON b.activity = ac.id
JOIN centers c
		ON c.id = p.center
WHERE 
       b.center in (:Scope)
		AND b.center not in (301,320,319,503)
		AND part.user_interface_type = 6
       AND b.starttime BETWEEN params.FromDate AND params.ToDate