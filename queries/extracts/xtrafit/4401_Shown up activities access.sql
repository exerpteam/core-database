-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    par.participant_center ||'p'|| par.participant_id AS memberid,
    TO_CHAR(longtodate(par.start_time), 'dd-mm-yyyy HH:MI') AS Start_time,
    a.name AS Activity_name,
    ag.name AS Activity_group
FROM
    participations par
JOIN
    bookings b
ON
    b.center = par.booking_center
AND b.id = par.booking_id
JOIN
    activity a
ON
    a.id = b.activity
JOIN
    activity_group ag
ON
    ag.id = a.activity_group_id
WHERE
    datetolongC(getcentertime(par.center),par.center) BETWEEN (par.START_TIME - 10*60*1000) AND
    (
        par.START_TIME + 5*60*1000)
AND par.STATE = 'PARTICIPATION'
AND par.on_waiting_list = 0
AND ag.id = 801