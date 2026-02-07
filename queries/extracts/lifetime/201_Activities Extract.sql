select 
case 
        when ac.activity_type = 2 THEN 'Class'
        when ac.activity_type = 3 THEN 'Resource Booking'
        when ac.activity_type = 9 THEN 'Course'
        when ac.activity_type = 7 THEN 'Resource Availability'
        when ac.activity_type = 4 THEN 'Staff Booking'
        when ac.activity_type = 6 THEN 'Staff Availability'
             ELSE 'unknown'
               END AS activityType,
        ag.name as activityGroup, 
        ac.name as activityName, 
        cg.name as colorGrup, 
        agg.name as ageGroups, 
        bpt.name as courseTypes, 
        bpl.name as courseLevel,
        case 
        when ac.course_schedule_type = 1 THEN 'Continuous'
                     ELSE 'Fixed'
               END AS coursescheduletype, 
        astc.minimum_staffs as MinimumStaffs,
        astc.maximum_staffs as MaximumStaffs,
        sg.name as StaffGroup,
        btc.name as time_config_name, -- New ES-28427
        ac.*

        
        
from 
        activity ac
left 
        join activity_group ag on ac.activity_group_id = ag.id
left 
        join colour_groups cg on cg.id = ac.colour_group_id
left 
        join age_groups agg on agg.id = ac.age_group_id
left 
        join booking_program_types bpt on ac.course_type_id = bpt.id
left 
        join lifetime.booking_program_levels bpl on ac.course_level_id = bpl.id

left    join activity_staff_configurations astc on ac.id=astc.activity_id

left    join staff_groups sg on astc.staff_group_id=sg.id

left join booking_time_configs btc on btc.id = ac.time_config_id  -- New ES-28427
where
        ac.state = 'ACTIVE'