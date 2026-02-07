-- This is the version from 2026-02-05
--  
WITH params AS (
        SELECT
                'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
                'Europe/Copenhagen' TZFORMAT
)
SELECT
        CAST(cp.external_id AS TEXT) AS "EXTERNALID",
        par.center || 'par' || par.id AS "PARTICIPATIONID",
        bo.center || 'book' || bo.id AS "CLASSID",
        par.participation_number AS "PARTICIPATIONNUMBER",
        (
                CASE
                        par.user_interface_type
                        WHEN 0 THEN 'OTHER'
                        WHEN 1 THEN 'CLIENT'
                        WHEN 2 THEN 'WEB'
                        WHEN 3 THEN 'KIOSK'
                        WHEN 4 THEN 'SCRIPT'
                        WHEN 5 THEN 'API'
                        WHEN 6 THEN 'MOBILE_API'
                        ELSE 'UNKNOWN'
                END
        ) AS "BOOKINGMECHANISM",
        par.state AS "STATUS",
        (
                CASE
                        par.state
                        WHEN 'PARTICIPATION' THEN TO_CHAR(
                                longtodateC(par.showup_time, par.center),
                                'yyyy-MM-dd HH24:MI:SS'
                        )
                        WHEN 'CANCELLED' THEN TO_CHAR(
                                longtodateC(par.cancelation_time, par.center),
                                'yyyy-MM-dd HH24:MI:SS'
                        )
                        ELSE TO_CHAR(
                                longtodateC(par.start_time, par.center),
                                'yyyy-MM-dd HH24:MI:SS'
                        )
                END
        ) AS "STATUSEVENTTIME",
        par.CANCELATION_REASON AS "CANCELREASON",
        (
                CASE
                        WHEN par.ON_WAITING_LIST IS FALSE THEN 0
                        ELSE 1
                END
        ) AS "WAITINGLIST",
        TO_CHAR(
                longtodateC(par.creation_time, par.center),
                'yyyy-MM-dd HH24:MI:SS'
        ) AS "CREATEDDATE",
        TO_CHAR(
                longtodateC(par.last_modified, par.center),
                'yyyy-MM-dd HH24:MI:SS'
        ) AS "LASTMODIFIEDDATE"
FROM
        fw.participations par
        JOIN fw.bookings bo ON bo.center = par.booking_center
        AND bo.id = par.booking_id
        JOIN fw.persons p ON par.participant_center = p.center
        AND par.participant_id = p.id
        JOIN fw.persons cp ON p.current_person_center = cp.center
        AND p.current_person_id = cp.id
        CROSS JOIN params
WHERE
        par.CENTER in ($$scope$$)
        AND par.last_modified between $$fromdate$$
        AND $$todate$$ + (86400 * 1000)