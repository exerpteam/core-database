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
 SELECT
     cp.EXTERNAL_ID::varchar                 AS "EXTERNALID",
         par.CENTER||'par'||par.ID               AS "PARTICIPATIONID",
         bo.CENTER||'book'||bo.ID                AS "CLASSID",
         par.PARTICIPATION_NUMBER                AS "PARTICIPATIONNUMBER",
         CASE  par.user_interface_type
                  WHEN 0 THEN 'OTHER'
                          WHEN 1 THEN 'CLIENT'
                          WHEN 2 THEN 'WEB'
                          WHEN 3 THEN 'KIOSK'
                          WHEN 4 THEN 'SCRIPT'
                          WHEN 5 THEN 'API'
                          WHEN 6 THEN 'MOBILE_API'
                          ELSE 'UNKNOWN' END                      AS "BOOKINGMECHANISM",
         par.state                               AS "STATUS",
         CASE  par.state
                 WHEN 'PARTICIPATION' THEN  TO_CHAR(longtodatetz(par.SHOWUP_TIME,TZFORMAT),DATETIMEFORMAT)
                     WHEN 'CANCELLED' THEN      TO_CHAR(longtodatetz(par.CANCELATION_TIME,TZFORMAT),DATETIMEFORMAT)
                     ELSE TO_CHAR(longtodatetz(par.START_TIME,TZFORMAT),DATETIMEFORMAT)
                    END                                 AS "STATUSEVENTTIME",
         par.CANCELATION_REASON                  AS "CANCELREASON",
         CASE par.ON_WAITING_LIST when false then 0 else 1 end as "WAITINGLIST",
         TO_CHAR(longtodatetz(par.creation_time,TZFORMAT),DATETIMEFORMAT) AS "CREATEDDATE",
         TO_CHAR(longtodatetz(par.LAST_MODIFIED,TZFORMAT),DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
 FROM
     BOOKINGS bo
 JOIN
     PARTICIPATIONS par
 ON
     bo.CENTER = par.BOOKING_CENTER
     AND bo.ID = par.BOOKING_ID
 JOIN
     PERSONS p
 ON
     par.PARTICIPANT_CENTER = p.CENTER
     AND par.PARTICIPANT_ID = p.ID
 JOIN
     PERSONS cp
 ON
     p.CURRENT_PERSON_CENTER = cp.CENTER
     AND p.CURRENT_PERSON_ID = cp.ID
 JOIN
     CENTERS c
 ON    c.id = bo.CENTER
    JOIN params
 ON
    params.center = par.CENTER 
 WHERE
     par.CENTER in ($$scope$$)
     AND par.LAST_MODIFIED >= PARAMS.FROMDATE
     AND par.LAST_MODIFIED < PARAMS.TODATE
UNION ALL
     SELECT 
        NULL AS "EXTERNALID",
        NULL AS "PARTICIPATIONID",
        NULL AS "CLASSID",
        NULL AS "PARTICIPATIONNUMBER",
        NULL AS "BOOKINGMECHANISM",
        NULL AS "STATUS",
        NULL AS "STATUSEVENTTIME",
        NULL AS "CANCELREASON",
        NULL AS "WAITINGLIST",
        NULL AS "CREATEDDATE",
        NULL AS "LASTMODIFIEDDATE"