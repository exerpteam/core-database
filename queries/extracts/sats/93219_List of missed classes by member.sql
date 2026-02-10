-- The extract is extracted from Exerp on 2026-02-08
--  
Select
b.center ||'book'|| b.id as bookingId,  
b.name as "class name",
b.activity as activityid,
to_char(longtodate(b.starttime),'YYYY-MM-DD HH24:MI:SS') as "start date time",
to_char(longtodate(b.stoptime),'YYYY-MM-DD HH24:MI:SS') as "End date time",
b.center as clubid,
c.name as "center",
staff.fullname "instructor",
par.cancelation_reason



From bookings b

JOIN
     STAFF_USAGE su
 ON
     b.CENTER = su.BOOKING_CENTER
     AND b.ID = su.BOOKING_ID
     AND su.STATE = 'ACTIVE'
     
JOIN
     PERSONS staff
 ON
     staff.CENTER = su.PERSON_CENTER
     AND staff.ID = su.PERSON_ID     

join participations par
on      
par.BOOKING_CENTER = b.center
AND par.BOOKING_ID = b.id        

join centers c
on
b.center = c.id

join persons p
on
p.center = par.PARTICIPANT_CENTER
and p.id = par.PARTICIPANT_ID


where
p.external_id in (:external_id)
and par.cancelation_time is not null
--and par.no_show_up_punish_state is not null
and par.cancelation_reason in ('NO_SHOW')
and longtodate(b.starttime) >= (:fromtime)
and longtodate(b.starttime) <= (:totime)