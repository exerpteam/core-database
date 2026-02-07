-- This is the version from 2026-02-05
--  
select att.center || 'att' || att.id as ClipId, att.PERSON_CENTER ||  'p' || att.PERSON_ID as MemberId, att.CENTER as Center, to_char(longtodate(att.START_TIME), 'YYYY-MM-DD HH24:MI') as DateTime, br.NAME
from FW.ATTENDS att
join FW.BOOKING_RESOURCES br on att.BOOKING_RESOURCE_CENTER = br.CENTER and att.BOOKING_RESOURCE_ID = br.id
join FW.PERSONS p on p.center = att.PERSON_CENTER and p.id = att.person_id
where att.CENTER in (:scope) and att.STATE = 'ACTIVE'
and br.ATTENDABLE = 1 and br.ATTEND_PRIVILEGE_ID not in (31,1481,2484,2884) and br.type in ('PERSON', 'SERVICE')
and p.status in (0,1,2,3,6,9)
and att.START_TIME >= :date_from
and att.START_TIME < (:date_to + 24 * 3600 * 1000)