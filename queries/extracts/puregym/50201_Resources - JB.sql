 SELECT br.center center_id, ce.name Center, bpg.name Booking_group_name,br.name Resource_name, br.COMENT coment,br.EXTERNAL_ID Door_ID
 FROM centers ce, BOOKING_RESOURCES br
 LEFT JOIN BOOKING_PRIVILEGE_GROUPS bpg
 on br.ATTEND_PRIVILEGE_ID = bpg.ID
 where ce.ID = br.center
 AND br.state='ACTIVE'
