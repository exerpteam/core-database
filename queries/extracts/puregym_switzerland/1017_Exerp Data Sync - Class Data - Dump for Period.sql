 WITH
     params AS
     (
         SELECT
             /*+ materialize */
                         'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
                         'Europe/London'         TZFORMAT
         
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
     AND bo.LAST_MODIFIED >= $$fromdate$$
     AND bo.LAST_MODIFIED < $$todate$$ + (86400 * 1000)
