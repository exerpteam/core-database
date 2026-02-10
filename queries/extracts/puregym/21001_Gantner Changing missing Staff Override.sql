-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     cen.NAME,
     br.NAME
 FROM
     BOOKING_RESOURCES br
 JOIN
     CENTERS cen
 ON
     cen.ID = br.CENTER
 JOIN
     USAGE_POINTS up
 ON
     up.CENTER = cen.ID
 JOIN
     CLIENTS cl
     ON cl.CENTER = cen.ID
     and cl.TYPE = 'CONTROLLER'
     and cl.LAST_CONTACT is not null
 WHERE
     br.NAME LIKE '%Changing%'
     and br.AVAILABILITY_STAFF is null
         and br.STATE = 'ACTIVE'
