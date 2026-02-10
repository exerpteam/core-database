-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    any_club_in_scope AS
    (
        SELECT
            id
        FROM
            (
                SELECT
                    id,
                    row_number() over () AS rownum
                FROM
                    centers
                WHERE
                    id IN ($$scope$$) ) x
        WHERE
            rownum =1
    )
     , params AS materialized
     (
         SELECT
       
             datetolongC(TO_CHAR(date_trunc('day', (CURRENT_TIMESTAMP - INTERVAL '5 days')), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
             datetolongC(TO_CHAR(date_trunc('day', (CURRENT_TIMESTAMP+ INTERVAL '1 days')), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE,
                         'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
                         'Europe/Zurich'         TZFORMAT
         FROM any_club_in_scope
     )
 SELECT DISTINCT
         bo.center::varchar                      AS "GYMID",
         bo.CENTER||'book'||bo.ID                AS "CLASSID",
         bo.name                                 AS "NAME",
     TO_CHAR(longtodatetz(bo.STARTTIME,TZFORMAT),DATETIMEFORMAT)     AS "STARTTIME",
     TO_CHAR(longtodatetz(bo.STOPTIME,TZFORMAT),DATETIMEFORMAT)      AS "ENDTIME",
     empcp.FULLNAME                          AS "INSTRUCTOR",
         bo.state                                AS "STATUS",
         TO_CHAR(longtodatetz(bo.creation_time,TZFORMAT),DATETIMEFORMAT) AS "CREATEDDATE",
         TO_CHAR(longtodatetz(bo.LAST_MODIFIED,TZFORMAT),DATETIMEFORMAT) AS "LASTMODIFIEDDATE",
     actgr.id                                                        AS "ACTIVITYGROUPID",
     actgr.name                                                      AS "ACTIVITYGROUPNAME"
 FROM
     BOOKINGS bo
 JOIN
     activity act
 ON
     act.id = bo.activity
 JOIN
     activity_group actgr
 ON
     actgr.id = act.activity_group_id
JOIN
     CENTERS c
 ON
     c.id = bo.CENTER
 CROSS JOIN params
 LEFT JOIN
     STAFF_USAGE stu
 ON
     stu.BOOKING_CENTER = bo.CENTER
     AND stu.BOOKING_ID = bo.ID
     AND stu.STATE = 'ACTIVE'
 LEFT JOIN
     PERSONS emp
 ON
     stu.PERSON_CENTER = emp.CENTER
     AND stu.PERSON_ID = emp.ID
 LEFT JOIN
     PERSONS empcp
 ON
     emp.CURRENT_PERSON_CENTER = empcp.CENTER
     AND emp.CURRENT_PERSON_ID = empcp.ID
 
 WHERE
     bo.CENTER in ($$scope$$)
     AND bo.LAST_MODIFIED >= PARAMS.FROMDATE
     AND bo.LAST_MODIFIED < PARAMS.TODATE
