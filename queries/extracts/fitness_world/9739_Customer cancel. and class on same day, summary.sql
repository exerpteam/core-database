-- This is the version from 2026-02-05
--  
Select
        sum(test2.customer_count) as customers,
        test2.GLOBAL_ACTIVITY_ID,
        test2.class_start
from
(
SELECT 
    count(par.participant_center||'p'||par.participant_id) as customer_count,
    act.NAME as GLOBAL_ACTIVITY_ID,
    to_char(longtodate(bo.STARTTIME), 'YYYY-MM-dd') as class_start
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
    and bo.STARTTIME >= :class_date_start
    and bo.STARTTIME <= :class_date_end
group by
    act.NAME,
    bo.STARTTIME
)
test2
group by
    test2.GLOBAL_ACTIVITY_ID,
    test2.class_start
order by
        test2.class_start,
        test2.GLOBAL_ACTIVITY_ID


	
	
