-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
			'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
			'Europe/London'         TZFORMAT
        FROM
            dual    )
SELECT 
    to_char(cp.EXTERNAL_ID)                 AS "EXTERNALID",
	par.CENTER||'par'||par.ID               AS "PARTICIPATIONID",
	bo.CENTER||'book'||bo.ID                AS "CLASSID",
	par.PARTICIPATION_NUMBER                AS "PARTICIPATIONNUMBER",
	DECODE (par.user_interface_type, 
	        0,'OTHER', 
			1,'CLIENT', 
			2,'WEB', 
			3,'KIOSK', 
			4,'SCRIPT', 
			5,'API', 
			6,'MOBILE_API', 
			'UNKNOWN')                      AS "BOOKINGMECHANISM",
	par.state                               AS "STATUS",
	DECODE( par.state, 
	       'PARTICIPATION', TO_CHAR(longtodatetz(par.SHOWUP_TIME,TZFORMAT),DATETIMEFORMAT),
		   'CANCELLED',     TO_CHAR(longtodatetz(par.CANCELATION_TIME,TZFORMAT),DATETIMEFORMAT),
		   TO_CHAR(longtodatetz(par.START_TIME,TZFORMAT),DATETIMEFORMAT)
		  )                                 AS "STATUSEVENTTIME",	
	par.CANCELATION_REASON                  AS "CANCELREASON",
	par.ON_WAITING_LIST                     AS "WAITINGLIST",
	TO_CHAR(longtodatetz(par.creation_time,TZFORMAT),DATETIMEFORMAT) AS "CREATEDDATE",
	TO_CHAR(longtodatetz(par.LAST_MODIFIED,TZFORMAT),DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
FROM
    PUREGYM.BOOKINGS bo
JOIN
    PUREGYM.PARTICIPATIONS par
ON
    bo.CENTER = par.BOOKING_CENTER
    AND bo.ID = par.BOOKING_ID
JOIN
    PUREGYM.PERSONS p	
ON
    par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.ID
JOIN
    PUREGYM.PERSONS cp	
ON
    p.CURRENT_PERSON_CENTER = cp.CENTER
    AND p.CURRENT_PERSON_ID = cp.ID	
JOIN
    PUREGYM.CENTERS c
ON    c.id = bo.CENTER
CROSS JOIN params
WHERE
    par.CENTER in ($$scope$$)
    AND par.LAST_MODIFIED >= $$fromdate$$
    AND par.LAST_MODIFIED < $$todate$$ + (86400 * 1000)