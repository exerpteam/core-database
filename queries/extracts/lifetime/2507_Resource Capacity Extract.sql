-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 	
		br.center AS "ClubID",
		c.name AS "ClubName",
		br.id AS "ResourceID",
		br.name AS "ResourceName",
		br.coment AS "Comment",
		br.type AS "ResourceType",
		br.state AS "State",
		br.show_calendar AS "ShowInCalendar",
		br.attendable AS "Attendable",
		br.attend_privilege_id AS "AccessPrivilegeID",
		bpg.name AS "AttendPrivilege",
		(CASE 
		WHEN br.age_restriction_type = 0 THEN 'NONE'
		WHEN br.age_restriction_type = 1 THEN 'Less Than'
		WHEN br.age_restriction_type = 2 THEN 'Greater Than'
		END) AS "AgeRestriction",

		br.age_restriction_value AS "AgeValue", 
		brg.name AS "ResourceGroup",		
		brc.maximum_participations AS "Max Capacity"

FROM booking_resources br

LEFT JOIN booking_resource_configs brc

ON
	br.center = brc.booking_resource_center
AND
	br.id = brc.booking_resource_id

JOIN centers c

ON
 	br.center = c.id	

LEFT JOIN booking_resource_groups brg

ON
	brc.group_id = brg.id

LEFT JOIN booking_privilege_groups bpg

ON
	br.attend_privilege_id = bpg.id