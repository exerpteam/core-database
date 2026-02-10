-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-13259
WITH mycenters AS 
(
   SELECT 
      id,
      datetolongTZ(to_char(:from_date,'YYYY-MM-DD HH24:MI'),c.TIME_ZONE) AS beginning,
      datetolongTZ(to_char(:to_date,'YYYY-MM-DD HH24:MI'),c.TIME_ZONE)+24*60*60*1000 AS ending 
   FROM CENTERS c
   WHERE id in (:Scope)
)
SELECT
    b.center || 'book' || b.id "Booking ID",
    longtodateC(b.STARTTIME, b.center) START_time,
    longtodateC(b.STOPTIME, b.center) end_time,
    pa.STATE PArticipation_State,
    a.NAME "Activity Name",
    pa.PARTICIPANT_CENTER||'p'||pa.PARTICIPANT_ID AS Participant
FROM
    BOOKINGS b
JOIN 
     mycenters
ON
    mycenters.id = b.center     

JOIN
    PARTICIPATIONS pa
ON
    b.center = pa.BOOKING_CENTER
    AND b.id = pa.BOOKING_ID
LEFT JOIN    
    ACTIVITY a
ON
    b.ACTIVITY = a.ID
    
WHERE
    b.starttime > mycenters.beginning
    AND b.starttime <= mycenters.ending
    AND TO_CHAR(longtodateC(b.STARTTIME, b.center), 'HH24') = '23'

