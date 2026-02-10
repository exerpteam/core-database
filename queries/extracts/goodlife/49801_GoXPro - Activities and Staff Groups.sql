-- The extract is extracted from Exerp on 2026-02-08
-- Created by: Sandra Gupta Created on: 10.22.24  Created for: GoXPro Integration POC
SELECT
        a.id AS "Activity ID",
        sg.name AS "Staff Group Name",
        sg.state AS "Staff Group State",
        p.external_id "Coach RefId",
        (CASE
                WHEN psg.scope_type = 'A' THEN a.name
                WHEN psg.scope_type = 'C' THEN c.name
                ELSE 'System'
        END) AS "Scope Name",
        psg.scope_id
FROM activity a
JOIN activity_staff_configurations ast ON a.id = ast.activity_id
JOIN staff_groups sg ON sg.id = ast.staff_group_id
JOIN person_staff_groups psg ON sg.id = psg.staff_group_id
JOIN persons p ON p.center = psg.person_center AND p.id = psg.person_id
LEFT JOIN areas ar ON ar.id = psg.scope_id AND psg.scope_type = 'A'
LEFT JOIN centers c ON c.id = psg.scope_id AND psg.scope_type = 'C'
WHERE 
        a.id IN (:activity_id)
        AND p.status NOT IN (4,5,7,8)