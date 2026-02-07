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
					  ELSE 'UNKNOWN' 
	END                      AS "BOOKINGMECHANISM",
	CASE  par.user_interface_type
			  WHEN 0 THEN 'OTHER'
					  WHEN 1 THEN 'CLIENT'
					  WHEN 2 THEN 'WEB'
					  WHEN 3 THEN 'KIOSK'
					  WHEN 4 THEN 'SCRIPT'
					  WHEN 5 THEN 'API'
					  WHEN 6 THEN 'MOBILE_API'
					  ELSE 'UNKNOWN' 
	END    AS "BOOKINGMECHANISM",			
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
    params
ON
    params.center = par.center
WHERE
    par.CENTER in ($$scope$$)
    AND par.LAST_MODIFIED >= params.FROMDATE
    AND par.LAST_MODIFIED < params.TODATE 