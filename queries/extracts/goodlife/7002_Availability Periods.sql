WITH
    Temp_Availability AS
    (
        SELECT
            a_Date, c.id as Scope_ID, c.name As Club_Name
        FROM
            generate_series( :startDate, :endDate, interval '1 day') a_DATE,
            centers c
        WHERE c.ID in (:scope)    
    ) 
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/sunday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as "Open Time", 
       REPLACE(REPLACE(xpath('/WEEKLY/sunday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','')  as "Close Time", '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 0
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/monday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/monday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 1
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/tuesday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/tuesday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 2
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/wednesday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/wednesday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 3
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/thursday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/thursday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 4
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/friday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/friday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 5
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Standard' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
       REPLACE(REPLACE(xpath('/WEEKLY/saturday/SIMPLETIMEINTERVAL/@FROM',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Opening_Hour, 
       REPLACE(REPLACE(xpath('/WEEKLY/saturday/SIMPLETIMEINTERVAL/@TO',
    convert_from(ap.schedule_value, 'UTF8')::xml)::text,'{',''),'}','') as Closing_Hour, '1' As "Club Status"
FROM Temp_Availability
JOIN availability_periods ap
ON  extract(dow FROM Temp_Availability.a_date) = 6
AND Temp_Availability.scope_id = ap.scope_id
AND ap.scope_type = 'C'
UNION ALL
SELECT Temp_Availability.Scope_ID as "Club ID", Temp_Availability.Club_Name as "Club", ap.name as "Availability Period Name", 'Override' As "Override or Standard Hours", to_char(a_date,'yyyy-MM-dd') As "Date", 
        ao.start_time as Opening_Hour, 
        ao.stop_time as Closing_Hour,
        '1' As "Club Status"
FROM Temp_Availability
LEFT JOIN availability_periods ap
ON Temp_Availability.scope_id = ap.scope_id AND ap.scope_type = 'C'
JOIN goodlife.availability_overrides ao
ON   ao.availability_period_id = ap.id
AND ao.override_date = Temp_Availability.a_date;


