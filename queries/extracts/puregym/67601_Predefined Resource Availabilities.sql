 SELECT x.center, x.name Resource_Name, x.ATTEND_AVAILABILITY_PERIOD_ID, ap.name Availability_Name FROM
 (
 SELECT
     br.ID,
     br.name,
     br.center,
     br.ATTEND_AVAILABILITY_PERIOD_ID,
     --extract(xmltype(br.ATTEND_AVAILABILITY, 871),'//DAILY/SIMPLETIMEINTERVAL') AS di,
     xpath('//DAILY/SIMPLETIMEINTERVAL', xmlparse(content convert_from(br.ATTEND_AVAILABILITY, 'UTF-8'))) as di,
     br.ATTEND_AVAILABILITY
   FROM BOOKING_RESOURCES br
 ) x
 LEFT JOIN
   AVAILABILITY_PERIODS ap
 ON
   ap.ID = x.ATTEND_AVAILABILITY_PERIOD_ID
 WHERE array_upper(di, 1) IS NULL
