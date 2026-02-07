SELECT
emp.PERSONCENTER || 'p' || emp.PERSONID AS PId,
	
	per.FULLNAME AS "Name",
	emp.CENTER || 'emp' || emp.ID AS EmpId,
	emp.LAST_LOGIN,
	emp.BLOCKED,
	list_groups   AS "Staff group(s)",
    c.SHORTNAME  AS "Club"
	
FROM
	EMPLOYEES emp

LEFT JOIN PERSONS per
ON
	emp.PERSONCENTER = per.CENTER
	AND emp.PERSONID = per.ID


JOIN
    centers c
ON
    c.ID = per.CENTER
LEFT JOIN
    (
        SELECT
            p.CENTER,
            p.id,
            STRING_AGG(sg.NAME, ',' ORDER BY sg.NAME) AS StaffGroups
        FROM
            persons p
        JOIN
            person_staff_groups ps
        ON
            ps.person_center = p.center
            AND ps.person_id = p.id
        JOIN
            STAFF_GROUPS sg
        ON
            sg.ID = ps.STAFF_GROUP_ID
        GROUP BY
            p.center,
            p.id,
            p.FULLNAME ) list_groups

ON
    list_groups.CENTER = per.Center
    AND list_groups.ID = per.id

WHERE
      per.center IN ($$center$$)


        