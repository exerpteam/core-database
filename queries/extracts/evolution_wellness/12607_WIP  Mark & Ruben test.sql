-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.person_center || 'p' || t1.person_id AS PersonID,
        t1.change_source_1st, 
        t1.change_attribute_1st,  
        t1.new_value_1st, 
        longToDateC(t1.entry_time_1st, t1.person_center) AS date_field_removed,  
        t1.empuser_1st,
        t1.change_source_2nd, 
        t1.new_value_2nd,  
        longToDateC(t1.entry_time_2nd, t1.person_center) AS date_field_added, 
        t1.empsuer_2nd,
        count(*) AS checkin_count
FROM
(
        SELECT
                pcl.person_center, 
                pcl.person_id,
                pcl.change_source AS change_source_1st, 
                pcl.change_attribute AS change_attribute_1st,  
                pcl.new_value AS new_value_1st, 
                pcl.entry_time AS entry_time_1st,  
                pcl.employee_center || 'emp' || pcl.employee_id AS empuser_1st,
                pcl2.change_source AS change_source_2nd, 
                pcl2.new_value AS new_value_2nd,  
                pcl2.entry_time AS entry_time_2nd,   
                pcl2.employee_center || 'emp' || pcl2.employee_id AS empsuer_2nd,
                (CASE
                        WHEN pcl2.entry_time IS NULL THEN dateToLongC(getCenterTime(pcl.person_center),pcl.person_center) ELSE pcl2.entry_time
                END) temp_enddate
        FROM evolutionwellness.person_change_logs pcl
        LEFT JOIN evolutionwellness.person_change_logs pcl2 ON pcl.id = pcl2.previous_entry_id
        WHERE
                pcl.change_attribute = '_eClub_PBLookupPartnerPersonId'
                AND pcl.employee_center = 999 
                AND pcl.employee_id = 207
) t1
LEFT JOIN evolutionwellness.checkins c
        ON t1.person_center = c.person_center 
        AND t1.person_id = c.person_id 
        AND c.checkin_time BETWEEN t1.entry_time_1st AND t1.temp_enddate
        AND c.checkin_result IN (1,2)
GROUP BY
        t1.person_center, 
        t1.person_id,
        t1.change_source_1st, 
        t1.change_attribute_1st,  
        t1.new_value_1st, 
        t1.entry_time_1st,  
        t1.empuser_1st,
        t1.change_source_2nd, 
        t1.new_value_2nd,  
        t1.entry_time_2nd,   
        t1.empsuer_2nd
  
        