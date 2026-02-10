-- The extract is extracted from Exerp on 2026-02-08
--  
select part.PARTICIPANT_CENTER || 'p' || part.PARTICIPANT_ID as MemberId, 
bk.center as Center,
part.CENTER || 'part' || part.ID as ParticipationId,
bk.NAME as Class, agr.NAME as Category, longtodate(part.CREATION_TIME) as BookedTime, longtodate(part.START_TIME) as StartTime, 
case when part.STATE = 'PARTICIPATION' then 'SHOWUP' when part.CANCELATION_REASON in ('USER') then 'CANCELLED_MEMBER' when part.CANCELATION_REASON in ('NO_SHOW') then 'NOSHOW' when part.CANCELATION_REASON in ('NO_SEAT') then 'NOSEAT' else 'CANCELLED_CENTER' end as STATUS, 
case 
    when part.USER_INTERFACE_TYPE in (1) then 'STAFF'
    when part.USER_INTERFACE_TYPE in (2) and part.CREATION_BY_CENTER = 114 and part.CREATION_BY_ID = 33670 then 'APP'
    when part.USER_INTERFACE_TYPE in (2,5) then 'WEB'
    when part.USER_INTERFACE_TYPE in (3) then 'KIOSK'
    else 'OTHER'
end as SOURCE,
case when part.MOVED_UP_TIME is not null then 'Y' else 'N' end as MovedFromWaitingList,
decode(part.ON_WAITING_LIST, 1, 'Y', 0, 'N') as OnWaitingList,
sus.InstructorId,
emp_per.FULLNAME
from FW.PARTICIPATIONS part 
join FW.BOOKINGS bk on bk.center = part.BOOKING_CENTER and bk.id = part.BOOKING_ID
join persons p on p.center = part.PARTICIPANT_CENTER and p.id = part.PARTICIPANT_ID
left join (
    select min(su.PERSON_CENTER ||'p' || su.PERSON_ID) as InstructorId, su.BOOKING_CENTER, su.BOOKING_ID from FW.STAFF_USAGE su group by su.BOOKING_CENTER, su.BOOKING_ID --where rownum <= 1
) sus on sus.BOOKING_CENTER = bk.center and sus.BOOKING_ID = bk.id
left join FW.PERSONS emp_per on emp_per.center || 'p' || emp_per.id = sus.InstructorId
join FW.ACTIVITY act on bk.ACTIVITY = act.id
join FW.ACTIVITY_GROUP agr on act.ACTIVITY_GROUP_ID = agr.ID
where 
part.state in ('PARTICIPATION', 'CANCELLED')

and part.START_TIME >= datetolong(to_char(trunc(exerpsysdate() - 4), 'YYYY-MM-DD HH24:MI'))
and part.START_TIME < datetolong(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD HH24:MI'))
and p.status in (0,1,2,3,6,9)

order by 1, part.START_TIME