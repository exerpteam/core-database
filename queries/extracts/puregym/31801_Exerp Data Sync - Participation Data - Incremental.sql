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
     , params AS
     (
         SELECT
             /*+ materialize  */
             datetolongC(TO_CHAR(TRUNC(CURRENT_TIMESTAMP)-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
             datetolongC(TO_CHAR(TRUNC(CURRENT_TIMESTAMP+1), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE,
                         'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
                         'Europe/London'         TZFORMAT
         FROM any_club_in_scope
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
            case par.ON_WAITING_LIST when false then 0 else 1 end as "WAITINGLIST",
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
 CROSS JOIN params
 WHERE
     par.CENTER in ($$scope$$)
     AND par.LAST_MODIFIED >= PARAMS.FROMDATE
     AND par.LAST_MODIFIED < PARAMS.TODATE
