 WITH
  params AS materialized
   (
         SELECT
             id   AS  center,
             CAST(datetolongC(TO_CHAR(CAST($$fromdate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS  FROMDATE,
             CAST(datetolongC(TO_CHAR(CAST($$todate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) + (86400 * 1000) AS TODATE,
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
         TO_CHAR(longtodatetz(bo.LAST_MODIFIED,TZFORMAT),DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
 FROM
     BOOKINGS bo
 JOIN 
    params
 ON
    params.center = bo.center    
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
     AND bo.LAST_MODIFIED >= params.FROMDATE
     AND bo.LAST_MODIFIED < params.TODATE 
