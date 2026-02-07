/*
SELECT br.name, br.center as BookingResourceCenter, br.id as BookingResourceId, att.id, att.center, att.person_center as PersonCenter, att.person_id, att.state, att.attend_using_card, 
    to_char(longtodatec(att.start_time, 100),'yyyy-MM-dd HH24:MI:SS') AS "START_TIME",
    to_char(longtodatec(att.stop_time, 100), 'yyyy-MM-dd HH24:MI:SS') AS "STOP_TIME",
     att.employee_center, att.employee_id, att.last_modified
FROM booking_resources br
	LEFT JOIN attends att
	    ON att.booking_resource_center = br.center and att.booking_resource_id = br.id
WHERE br.name like 'mind%'
 */

-- TO_CHAR(longtodateC(ar.entry_time, 100), 'YYYY-MM-dd HH24:MI') As EntryTime,

/*
SELECT br.name, att.*
FROM attends att
  JOIN booking_resources br
    ON att.booking_resource_center = br.center and att.booking_resource_id = br.id
WHERE br.name like 'mind%'
*/

/*
SELECT br.name
	, att.center
	, att.id
    , cp.external_id AS "PERSON_ID"
    , to_char(longtodatec(att.start_time, 100),'yyyy-MM-dd HH24:MI:SS') AS "START_TIME"
    , to_char(longtodatec(att.stop_time, 100),'yyyy-MM-dd HH24:MI:SS') AS "STOP_TIME"
	, att.attend_using_card
	, att.state
	, att.booking_resource_center
	, att.booking_resource_id
	, att.person_center
	, att.person_id
	, att.employee_center
	, att.employee_id
	, att.last_modified
FROM attends att
     LEFT JOIN persons p ON p.center = att.person_center AND p.id = att.person_id
     LEFT JOIN persons cp ON cp.center = p.transfers_current_prs_center AND cp.id = p.transfers_current_prs_id
   JOIN booking_resources br
    ON att.booking_resource_center = br.center and att.booking_resource_id = br.id
WHERE br.name like 'mind%'
*/

-- SELECT br.* FROM booking_resources AS br WHERE name like 'mind%' LIMIT 100
-- SELECT att.* FROM attends att LIMIT 100
/*
FROM attends att
     LEFT JOIN persons p ON p.center = att.person_center AND p.id = att.person_id
     LEFT JOIN persons cp ON cp.center = p.transfers_current_prs_center AND cp.id = p.transfers_current_prs_id;
*/
-- select * from bi_resources limit 100