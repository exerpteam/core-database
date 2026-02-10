-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    a.PERSON_CENTER || 'p' || a.PERSON_ID AS "Medlems ID",
    longtodate(a.START_TIME) AS "Besøgstidspunkt",
    br.NAME AS "Gate",
    br.ID AS "Gate ID",
	de.name as "Specific source unit",
   	ups.reader_device_sub_id AS "Specific source ID",
    upr.name                 AS "Specific source action",
    ups.external_id          AS "Specific source External ID",
    cl.NAME AS "Client Navn",
    de.NAME AS "Device Navn",
    cen.NAME AS "Center Navn",
	de.ID
FROM ATTENDS a
JOIN usage_points up
    ON up.center = a.BOOKING_RESOURCE_CENTER
   AND up.id = a.BOOKING_RESOURCE_ID
JOIN fw.usage_point_sources ups
    ON ups.usage_point_center = up.center
   AND ups.usage_point_id = up.id
JOIN fw.usage_point_resources upr
    ON upr.center = ups.action_center
   AND upr.id = ups.action_id
JOIN fw.usage_point_action_res_link upalk
    ON upalk.action_center = ups.action_center
   AND upalk.action_id = ups.action_id
JOIN fw.booking_resources br
    ON br.center = upalk.resource_center
   AND br.id = upalk.resource_id
JOIN clients cl
    ON cl.id = ups.client_id
JOIN devices de
    ON de.id = ups.reader_device_id
JOIN centers cen
    ON cen.id = up.center
WHERE
    a.CENTER = 237
  AND a.START_TIME >= CAST(datetolong(to_char(cast(:STARTDATE as date),'YYYY-MM-DD HH24:MI')) AS BIGINT)
  AND a.START_TIME <= CAST(datetolong(to_char(cast(:ENDDATE as date),'YYYY-MM-DD HH24:MI')) AS BIGINT)
--AND de.ID = 223296 --Gat Swimming
AND 
de.name ~* '(swim|svøm)'

ORDER BY
    a.START_TIME;
