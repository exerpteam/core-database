 SELECT
     p.FIRSTNAME,
     p.LASTNAME,
     p.CENTER || 'p' || p.ID                                         AS Pref,
     p.BIRTHDATE                                                     AS Birthdate,
         floor(months_between(current_timestamp, p.BIRTHDATE) / 12)                                AS Age,
 CASE  PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
         p.sex                                                                                                                   AS Gender,
     e.IDENTITY                                                      AS Pin,
     cen.NAME                                                        AS HomeClub,
     cen2.NAME                                                       AS VisitClub,
     br.NAME                                                         AS AccessPoint,
     TO_CHAR(TRUNC(longToDateTZ(att.START_TIME,'Europe/London'),'HH'),'dd-MM-YYYY') AS "Visit date",
     TO_CHAR(longtodatetz(att.START_TIME,'Europe/London'),'HH24:MI:SS') AS "Time"
 FROM
     PERSONS p
 JOIN
     ATTENDS att
 ON
     p.CENTER = att.PERSON_CENTER
     AND p.ID = att.PERSON_ID
 JOIN
     BOOKING_RESOURCES br
 ON
     br.CENTER = att.BOOKING_RESOURCE_CENTER
     AND br.ID = att.BOOKING_RESOURCE_ID
 JOIN
     CENTERS cen
 ON
     cen.ID = p.CENTER
 JOIN
     CENTERS cen2
 ON
     cen2.ID = att.BOOKING_RESOURCE_CENTER
 LEFT JOIN
     ENTITYIDENTIFIERS e
 ON
     e.IDMETHOD = 5
     AND e.ENTITYSTATUS = 1
     AND e.REF_CENTER=p.CENTER
     AND e.REF_ID = p.ID
     AND e.REF_TYPE = 1
 WHERE
     att.CENTER IN (:scope)
     AND att.START_TIME BETWEEN :startdate AND :enddate
