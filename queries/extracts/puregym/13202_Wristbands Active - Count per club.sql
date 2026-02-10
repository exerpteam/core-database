-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     COALESCE(c.NAME,'Grand') as "Club Name",
     c.id   AS "Club ID",
     COALESCE(a.NAME,'Total') AS "Regional Manager",
     COUNT(*) as "Active Wristbands"
 FROM
     (
         SELECT
             dateToLong(to_char(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI')) AS DATETIME
          ) PARAMS,
     ENTITYIDENTIFIERS e
 JOIN
     PERSONS p
 ON
     p.center = e.REF_CENTER
     AND p.id = e.REF_ID
 JOIN
     PERSONS p2
 ON
     p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
     AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
 LEFT JOIN
     CENTERS cen
 ON
     cen.ID = p.CENTER
 JOIN
     CENTERS c
 ON
     p.CENTER = c.id
 JOIN
     AREA_CENTERS AC
 ON
     C.ID = AC.CENTER
 JOIN
     AREAS A
 ON
     A.ID = AC.AREA
     AND A.PARENT = 61
 WHERE
     e.REF_TYPE = 1
     AND e.IDMETHOD = 4
     AND e.ENTITYSTATUS = 1
     AND e.REF_CENTER IN ($$scope$$)
     AND e.START_TIME < params.datetime
     AND (
         e.STOP_TIME > params.datetime
         OR e.STOP_TIME IS NULL)
     GROUP BY
     grouping sets ( (c.name,c.ID,A.NAME), () )
 order by 4 desc
