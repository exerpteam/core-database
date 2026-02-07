-- This is the version from 2026-02-05
--  
SELECT 
    par.participant_center||'p'||participant_id as customer,
    act.NAME  AS GLOBAL_ACTIVITY_ID,
    to_char(longtodate(bo.STARTTIME), 'YYYY-MM-dd HH24:MI') as class_start,
    to_char(longtodate(par.cancelation_time), 'YYYY-MM-dd HH24:MI') as
partition_cancelation,
    decode (par.user_interface_type, 1,'Client', 2, 'WEB', 3, 'Kiosk', 0, 'API') as
creation_interface,
    decode (par.cancelation_interface_type, 1,'Client', 2, 'WEB', 3, 'Kiosk', 0, 'API') as
cancelation_interface
FROM
     fw.persons p
JOIN fw.participations par
    ON
        par.PARTICIPANT_CENTER = p.CENTER
    AND par.PARTICIPANT_ID = p.id
left JOIN fw.bookings bo
    ON
        par.BOOKING_ID = bo.ID
    AND par.BOOKING_CENTER = bo.CENTER
left JOIN fw.activities_new act
    ON
        bo.ACTIVITY = act.id
WHERE 
        act.ACTIVITY_TYPE = 2 
    and par.cancelation_reason = 'USER'
    and bo.center in (:center)
    and to_char(longtodate(par.cancelation_time), 'YYYY-MM-dd') = to_char(longtodate(bo.STARTTIME), 'YYYY-MM-dd')
    and longtodate(bo.STARTTIME) >= :class_date_start
	and longtodate(bo.STARTTIME) <= :class_date_end
order by
    bo.center,
    bo.STARTTIME