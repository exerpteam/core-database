-- This is the version from 2026-02-05
--  
WITH params AS MATERIALIZED 

( 

         SELECT 

                datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - INTERVAL '5 days','YYYY-MM-DD'),c.id) AS fromdate, 

                datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)-1 AS todate, 

                c.id 

         FROM centers c 

         WHERE 

                c.id IN (:Scope) 

) 

SELECT 

        ( 

            Select  cp.external_id::TEXT 

            From    fw.persons p 

                    JOIN fw.persons cp 

                    ON p.current_person_center = cp.center AND p.current_person_id = cp.id 

            WHERE   par.participant_center = p.center AND par.participant_id = p.id 

        ) AS "EXTERNALID", 

        par.center || 'par' || par.id AS "PARTICIPATIONID", 

        bo.center || 'book' || bo.id AS "CLASSID", 

        par.participation_number AS "PARTICIPATIONNUMBER", 

        CASE par.user_interface_type 

                WHEN 0 THEN 'OTHER' 

                WHEN 1 THEN 'CLIENT' 

                WHEN 2 THEN 'WEB' 

                WHEN 3 THEN 'KIOSK' 

                WHEN 4 THEN 'SCRIPT' 

                WHEN 5 THEN 'API' 

                WHEN 6 THEN 'MOBILE_API' 

                ELSE 'UNKNOWN'  

        END AS "BOOKINGMECHANISM", 

        par.state AS "STATUS", 

        CASE par.state 

                WHEN 'PARTICIPATION' THEN TO_CHAR(longtodateC(par.showup_time,par.center),'yyyy-MM-dd HH24:MI:SS') 

                WHEN 'CANCELLED' THEN TO_CHAR(longtodateC(par.cancelation_time,par.center),'yyyy-MM-dd HH24:MI:SS') 

                ELSE TO_CHAR(longtodateC(par.start_time,par.center),'yyyy-MM-dd HH24:MI:SS') 

        END AS "STATUSEVENTTIME", 

        par.CANCELATION_REASON AS "CANCELREASON", 

        (par.ON_WAITING_LIST::boolean)::int AS "WAITINGLIST", 

        TO_CHAR(longtodateC(par.creation_time,par.center),'yyyy-MM-dd HH24:MI:SS') AS "CREATEDDATE", 

        TO_CHAR(longtodateC(par.last_modified,par.center),'yyyy-MM-dd HH24:MI:SS') AS "LASTMODIFIEDDATE" 

FROM fw.participations par 

JOIN params ON 

        par.center = params.id 

JOIN fw.bookings bo 

        ON bo.center = par.booking_center AND bo.id = par.booking_id 

WHERE   par.last_modified between params.fromdate AND params.todate 