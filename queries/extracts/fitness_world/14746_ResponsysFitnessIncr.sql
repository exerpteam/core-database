-- This is the version from 2026-02-05
--  
select att.center || 'att' || att.id as AttendId, att.PERSON_CENTER ||  'p' || att.PERSON_ID as MemberId, att.CENTER as Center, to_char(longtodate(att.START_TIME), 'YYYY-MM-DD HH24:MI') as DateTime

from FW.ATTENDS att
join FW.BOOKING_RESOURCES br on att.BOOKING_RESOURCE_CENTER = br.CENTER and att.BOOKING_RESOURCE_ID = br.id
join FW.PERSONS p on p.center = att.PERSON_CENTER and p.id = att.person_id
where att.CENTER in (:scope) and att.STATE = 'ACTIVE'
and br.ATTEND_PRIVILEGE_ID in (31,1481,2484)
and p.status in (0,1,2,3,6,9) 
and att.START_TIME >= datetolong(to_char(trunc(exerpsysdate() - 4), 'YYYY-MM-DD HH24:MI'))
and att.START_TIME < datetolong(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD HH24:MI'))