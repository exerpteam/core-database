-- This is the version from 2026-02-05
--  
select att.PERSON_CENTER ||  'p' || att.PERSON_ID as MemberId, att.CENTER as Center, to_char(longtodate(att.START_TIME), 'YYYY-MM-DD HH24:MI') as DateTime
from FW.ATTENDS att
join FW.BOOKING_RESOURCES br on att.BOOKING_RESOURCE_CENTER = br.CENTER and att.BOOKING_RESOURCE_ID = br.id
where att.PERSON_CENTER in (:scope) and att.STATE = 'ACTIVE'
and br.ATTEND_PRIVILEGE_ID = 31