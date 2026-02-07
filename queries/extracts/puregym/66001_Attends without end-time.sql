 SELECT
         /*+ index(a IDX_ATTEND_START_TIME) */
     c.ID                                AS "Centre id",
     c.NAME                              AS "Centre name",
     p.CENTER || 'p' || p.ID             AS "Member id",
     p.EXTERNAL_ID                       AS "Member external id",
     br.NAME                             AS "Resource",
     TO_CHAR(longtodatec(a.START_TIME, a.CENTER),'YYYY-MM-DD HH24:MI') AS "Start time",
     a.STOP_TIME                         AS "End time",
     bpg.NAME AS "Access group name"
 FROM
     ATTENDS a
 JOIN
     CENTERS c
 ON
     c.ID = a.CENTER
 JOIN
     PERSONS p
 ON
     p.CENTER = a.PERSON_CENTER
 AND p.ID = a.PERSON_ID
 JOIN
     BOOKING_RESOURCES br
 ON
     br.CENTER = a.BOOKING_RESOURCE_CENTER
 AND br.ID = a.BOOKING_RESOURCE_ID
 LEFT JOIN
         BOOKING_PRIVILEGE_GROUPS bpg ON bpg.ID = br.ATTEND_PRIVILEGE_ID
 WHERE
         a.START_TIME BETWEEN $$FromDate$$ AND $$ToDate$$ + (24*60*60*1000)
     AND a.STOP_TIME IS NULL
     AND a.center in (:Scope)
