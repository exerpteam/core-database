-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS materialized
     (
         SELECT
             id   AS  center,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,
             'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
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
     params
 ON 
     bo.center = params.center     
 JOIN
     activity act
 ON
     act.id = bo.activity
 JOIN
     activity_group actgr
 ON
     actgr.id = act.activity_group_id
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
UNION ALL
     SELECT 
        NULL AS "GYMID",
        NULL AS "CLASSID",
        NULL AS "NAME",
        NULL AS "STARTTIME",
        NULL AS "ENDTIME",
        NULL AS "INSTRUCTOR",
        NULL AS "STATUS",
        NULL AS "CREATEDDATE",
        NULL AS "LASTMODIFIEDDATE",
        NULL AS "ACTIVITYGROUPID",
        NULL AS "ACTIVITYGROUPNAME"
