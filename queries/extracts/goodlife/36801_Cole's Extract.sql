-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
  
  SELECT
  
    datetolongTZ(TO_CHAR(current_date - :Offset,'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateFrom,
    datetolongTZ(TO_CHAR(current_date,'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateTo,
    c.id AS centerid
  FROM
    goodlife.centers c
  WHERE
    c.time_zone IS NOT NULL
)
SELECT
a.name
,b.center||'book'||b.id AS booking_id
,TO_CHAR(LONGTODATEC(b.starttime,b.center),'YYYY-MM-DD HH24:MI:SS') AS date_time
,COUNT(par.*)
,par.state
,par.cancelation_reason
,b.class_capacity

FROM
bookings b
JOIN params
ON params.centerid = b.center
AND b.starttime BETWEEN params.cutDateFrom AND params.cutDateto
AND b.state = 'ACTIVE'
JOIN activity a
ON b.activity = a.id
AND a.activity_type = 2 -- Class Booking
JOIN participations par
ON par.booking_center = b.center
AND par.booking_id = b.id
-- AND par.state = 'PARTICIPATION'
GROUP BY
a.name
,b.center
,b.id
,par.state
,par.cancelation_reason
,b.class_capacity