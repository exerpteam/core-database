-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        par.center AS "Center",
        TO_CHAR(longtodateC(par.creation_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Created",
        TO_CHAR(longtodateC(par.last_modified, par.center), 'dd-MM-YYYY HH24:MI') AS "Last adjusted",
        par.participation_number AS "Participant number",
        TO_CHAR(longtodateC(par.start_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Start",
        TO_CHAR(longtodateC(par.stop_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Finish",
        par.booking_center AS "Booking Center",
        par.booking_id AS "Booking ID",
        par.participant_center AS "Member Center",
        CAST(par.participant_id AS TEXT) AS "Member ID",
        TO_CHAR(longtodateC(par.showup_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Attendance time",
        par.on_waiting_list "Waiting list",
        TO_CHAR(longtodateC(par.cancelation_time, par.center), 'dd-MM-YYYY HH24:MI') AS "Cancellation time"
FROM participations par
WHERE
        (par.participant_center,par.participant_id) IN (:memberid)