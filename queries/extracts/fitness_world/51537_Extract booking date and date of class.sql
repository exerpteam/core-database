-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-7278
SELECT 
   TO_CHAR(longtodate(par.CREATION_TIME),'DD-MM-YYYY HH:MM') AS "Date of booking", 
   TO_CHAR(longtodate(pu.TARGET_START_TIME),'DD-MM-YYYY') "Date of booked class",
   pr.NAME  AS "Membership", pu.STATE, par.STATE, pu.PERSON_ID, pu.PERSON_CENTER
FROM 
   BOOKINGS b
JOIN
   PARTICIPATIONS par
ON
   b.CENTER = par.BOOKING_CENTER
   AND b.ID = par.BOOKING_ID
JOIN
   PRIVILEGE_USAGES  pu
ON
   pu.PRIVILEGE_TYPE = 'BOOKING' 
   AND pu.TARGET_SERVICE = 'Participation'
   AND pu.PERSON_CENTER =  par.PARTICIPANT_CENTER
   AND pu.PERSON_ID =  par.PARTICIPANT_ID  
   AND pu.TARGET_CENTER = par.CENTER
   AND pu.TARGET_ID = par.ID
JOIN
   SUBSCRIPTIONS s
ON
   s.center = pu.SOURCE_CENTER
   AND s.id = pu.SOURCE_ID
JOIN
   PRODUCTS pr
ON
   pr.center = s.SUBSCRIPTIONTYPE_CENTER
   AND pr.id = s.SUBSCRIPTIONTYPE_ID
WHERE
  pu.TARGET_START_TIME >= :FROM_DATE
  AND pu.TARGET_START_TIME < :TO_DATE + 24*3600*1000
  AND par.STATE <> 'CANCELLED'
  AND par.CENTER in (:Centers)
