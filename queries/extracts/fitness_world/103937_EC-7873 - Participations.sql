-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
par.center AS "Center",
TO_CHAR(longtodateC(par.creation_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Oprettet",
TO_CHAR(longtodateC(par.last_modified, par.center), 'dd-MM-YYYY HH24:MI') AS "Senest justeret",
par.participation_number AS "Deltagernummer",
TO_CHAR(longtodateC(par.start_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Start",
TO_CHAR(longtodateC(par.stop_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Slut",
par.booking_center AS "Booking Center",
par.booking_id AS "Booking ID",
par.participant_center AS "Medlem Center",
par.participant_id::varchar(20) AS "Medlem ID",
TO_CHAR(longtodateC(par.showup_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Fremmøde tidspunkt",
par.on_waiting_list "Venteliste",
TO_CHAR(longtodateC(par.cancelation_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Aflysningstidspunkt"
FROM
participations par
WHERE
par.participant_center ||'p'|| par.participant_id IN (:memberid)