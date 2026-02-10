-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT br.center center_id, ce.name Center, bpg.name Booking_group_name,br.name Resource_name, br.COMENT coment
 FROM centers ce, BOOKING_RESOURCES br
 LEFT JOIN BOOKING_PRIVILEGE_GROUPS bpg
 on br.ATTEND_PRIVILEGE_ID = bpg.ID
 where ce.ID = br.center
 and br.COMENT like '%IN%'
 AND br.state='ACTIVE'
 and bpg.name <> 'Fitness'
