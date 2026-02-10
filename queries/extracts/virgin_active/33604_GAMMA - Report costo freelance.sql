-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT  DISTINCT c.SHORTNAME, CONCAT(CONCAT(cast(p.CENTER as char(3)),'p'), cast(p.ID as varchar(8))) as personId, p.FULLNAME as nominativo, a.NAME as corso,
  longtodatec(b.starttime, b.center) as inizio,
  longtodatec(b.stoptime, b.center) as fine,
 b.STOPTIME/60/1000-b.STARTTIME/60/1000 AS minuti,
 ps.SALARY, CASE WHEN ps.STAFF_GROUP_ID =  801 THEN 'Senior' ELSE 'Junior' END AS GrUPPO from PERSONS p
 INNER JOIN
 PERSON_STAFF_GROUPS ps
 on
 p.ID = ps.PERSON_ID
 AND
 p.CENTER = ps.PERSON_CENTER
 INNER JOIN
 STAFF_USAGE
 su
 ON su.PERSON_CENTER = p.CENTER
 AND
 su.PERSON_ID = p.ID
 INNER JOIN
 BOOKINGS b
 ON b.ID = su.BOOKING_ID
 AND
 b.CENTER = su.BOOKING_CENTER
 INNER JOIN
 ACTIVITY a
 ON a.ID = b.ACTIVITY
 INNER JOIN
 CENTERS c
 ON c.ID = b.CENTER
 WHERE ps.STAFF_GROUP_ID IN( 801, 1601)
 AND
 c.ID IN(:scope)
 --and p.ID = 230 AND p.CENTER = 106
 and  LongToDate(b.STARTTIME) BETWEEN $$dataDa$$ and $$dataA$$ + 1
 and b.STATE = 'ACTIVE'
 ORDER BY c.SHORTNAME, p.FULLNAME, longtodatec(b.starttime, b.center)
