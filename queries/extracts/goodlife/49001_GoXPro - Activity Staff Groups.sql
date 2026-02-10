-- The extract is extracted from Exerp on 2026-02-08
-- Created by: Sandra Gupta Created for: GXP Integration  Created on: Sept 17, 2024. Enable for API set by Mark Hanna as requested by Sandra via email Sept 18, 2024. 
SELECT
  a.id as "Activity ID",
  a.name as "Activity Name",
  sg.name as "Staff Group",
  CASE
  a.activity_type
  WHEN 1 THEN 'General'
  WHEN 2 THEN 'Class'
  WHEN 3 THEN 'Resource booking'
  WHEN 4 THEN 'Staff booking'
  WHEN 5 THEN 'Meeting'
  WHEN 6 THEN 'Staff availability'
  WHEN 7 THEN 'Resource availability'
  WHEN 8 THEN 'ChildCare'
  WHEN 9 THEN 'Course program'
  WHEN 10 THEN 'Task'
  WHEN 11 THEN 'Camp'
  WHEN 12 THEN 'Camp elective'
  END AS "Activity Type",
  a.state as "Activity State"
  FROM activity a
  JOIN activity_staff_configurations ac on ac.activity_id = a.id
  JOIN staff_groups sg on sg.id = ac.staff_group_id