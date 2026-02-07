SELECT
    T1.name as "Activity Name",
    C.name as "Scope Availability",
    T1.id as "Activity ID",
    T1.activity_group_id,
            T1.activitytype,
            T1.age_group_id,
            T1.allow_recurring_bookings,
            T1.availability,
            T1.available_from,
            T1.available_to,
            T1.description,
            T1.duration_list,
            T1.external_id,
            T1.requires_planning
FROM
    (
        SELECT
            LEFT(regexp_split_to_table(a.availability, E','),1)   AS C_OR_A,
            SUBSTR(regexp_split_to_table(a.availability, E','),2) AS split_fruits,
            CASE
                WHEN a.activity_type = 2
                THEN 'Class'
                WHEN a.activity_type = 3
                THEN 'Resource Booking'
                WHEN a.activity_type = 9
                THEN 'Course'
                WHEN a.activity_type = 7
                THEN 'Resource Availability'
                WHEN a.activity_type = 4
                THEN 'Staff Booking'
                WHEN a.activity_type = 6
                THEN 'Staff Availability'
                ELSE 'unknown'
            END AS activityType,
            a.name,
            a.activity_group_id,
            a.activity_type,
            a.age_group_id,
            a.allow_recurring_bookings,
            a.availability,
            a.available_from,
            a.available_to,
            a.description,
            a.duration_list,
            a.id,
            a.external_id,
            a.requires_planning
        FROM
            lifetime.activity a
            -- WHERE
            --   LEFT(regexp_split_to_table(a.availability, E','),1)='C'
    ) AS T1
JOIN
    lifetime.centers c
ON
    t1.split_fruits = '' ||c.id
AND T1.C_OR_A= 'C'
UNION
SELECT
    T1.name,
    a.name as Availability,
    T1.activity_group_id,
    T1.id AS "Activity ID",
            T1.activitytype,
            T1.age_group_id,
            T1.allow_recurring_bookings,
            T1.availability,
            T1.available_from,
            T1.available_to,
            T1.description,
            T1.duration_list,
            T1.external_id,
            T1.requires_planning
FROM
    (
        SELECT
            LEFT(regexp_split_to_table(a.availability, E','),1)   AS C_OR_A,
            SUBSTR(regexp_split_to_table(a.availability, E','),2) AS split_fruits,
            CASE
                WHEN a.activity_type = 2
                THEN 'Class'
                WHEN a.activity_type = 3
                THEN 'Resource Booking'
                WHEN a.activity_type = 9
                THEN 'Course'
                WHEN a.activity_type = 7
                THEN 'Resource Availability'
                WHEN a.activity_type = 4
                THEN 'Staff Booking'
                WHEN a.activity_type = 6
                THEN 'Staff Availability'
                ELSE 'unknown'
            END AS activityType,
            a.name,
            a.activity_group_id,
            a.activity_type,
            a.age_group_id,
            a.allow_recurring_bookings,
            a.availability,
            a.available_from,
            a.available_to,
            a.description,
            a.duration_list,
            a.id,
            a.external_id,
            a.requires_planning
        FROM
            lifetime.activity a
            -- WHERE
            --   LEFT(regexp_split_to_table(a.availability, E','),1)='C'
    ) AS T1
JOIN
    lifetime.areas a
ON
    t1.split_fruits = '' ||a.id
AND T1.C_OR_A= 'A'
UNION
SELECT
    a.name,
    'SYSTEM/GLOBAL Level' ,
    A.id AS "Activity ID",
    a.activity_group_id,
            CASE
                WHEN a.activity_type = 2
                THEN 'Class'
                WHEN a.activity_type = 3
                THEN 'Resource Booking'
                WHEN a.activity_type = 9
                THEN 'Course'
                WHEN a.activity_type = 7
                THEN 'Resource Availability'
                WHEN a.activity_type = 4
                THEN 'Staff Booking'
                WHEN a.activity_type = 6
                THEN 'Staff Availability'
                ELSE 'unknown'
            END AS activityType,
            a.age_group_id,
            a.allow_recurring_bookings,
            a.availability,
            a.available_from,
            a.available_to,
            a.description,
            a.duration_list,
            a.external_id,
            a.requires_planning
FROM
    lifetime.activity a
    Where a.availability = 'T1';
    
    
    
  
    
    
    
    

