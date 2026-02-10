-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.name       		AS "Club",
    p.center ||'p'|| p.id AS PersonId,
    p.external_id 	 	AS "External ID",
    s.binding_end_date 	 	AS "MCP End Date",
    srp.start_date         	AS "Start Date",
    srp.end_date   	 	AS "End Date",
    (srp.end_date::date - srp.start_date::date)+1   AS "Duration",
    CASE 
	WHEN srp.Type = 'FREE_ASSIGNMENT' THEN 'Free Periods'
	ELSE srp.Type END	AS "Type",
    srp.text			AS "Comment",
    longToDateC(srp.entry_time, c.id)		AS "Entry_Date",
    staff.fullname       	AS "Created_by"
FROM Persons p
JOIN Centers c
	ON c.id = p.center
JOIN Subscriptions s
	ON s.owner_center = p.center
	AND s.owner_id = p.id
	AND s.state in (2,4,7,8) 
JOIN subscription_reduced_period srp
	ON srp.subscription_center = s.center
	AND srp.subscription_id = s.id
LEFT JOIN
    evolutionwellness.employees emp
ON
    emp.center = srp.employee_center
AND emp.id = srp.employee_id
LEFT JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
WHERE
	srp.Type = 'FREE_ASSIGNMENT'
	AND srp.start_date >= (:From)
	AND srp.End_Date <= (:To)
--	AND srp.End_Date >= DATE(NOW())
	AND srp.state != 'CANCELLED'
	AND p.center IN (:Scope)