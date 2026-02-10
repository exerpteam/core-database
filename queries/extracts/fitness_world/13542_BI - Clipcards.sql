-- The extract is extracted from Exerp on 2026-02-08
--  
select att.PERSON_CENTER ||  'p' || att.PERSON_ID as MemberId, att.CENTER as Center, to_char(longtodate(att.START_TIME), 'YYYY-MM-DD HH24:MI') as DateTime, br.NAME
from ATTENDS att
join BOOKING_RESOURCES br on att.BOOKING_RESOURCE_CENTER = br.CENTER and att.BOOKING_RESOURCE_ID = br.id
where att.PERSON_CENTER in (:scope) and att.STATE = 'ACTIVE'
and br.ATTENDABLE = 1 and br.ATTEND_PRIVILEGE_ID not in (31,1481,2484,2884) and br.type in ('PERSON', 'SERVICE')
