-- This is the version from 2026-02-05
--  
select 
    b.center,
    to_char(longToDate(b.starttime),'yyyy-mm-dd') as start_date,
    b.name as class_name,
    count(b.main_booking_id)
from 
    bookings b
where
    b.starttime >= :from_date
and b.starttime <= :to_Date
and b.state like :state
group by
    b.center,
    to_char(longToDate(b.starttime),'yyyy-mm-dd'),
    b.name
order by
	b.center,
    to_char(longToDate(b.starttime),'yyyy-mm-dd'),
    b.name
