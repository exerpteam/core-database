-- The extract is extracted from Exerp on 2026-02-08
-- Created by: Monali Patel/Sandra Gupta  Created for: Support and PDS  Created on:  9.30.24
SELECT DISTINCT ON (person_change_logs.person_id) 
    person_change_logs.person_id, 
    person_change_logs.person_center, 

    -- member details
    persons.fullname,
	persons.firstname,
	persons.lastname,
    persons.external_id,
    persons.current_person_center AS HomeClub,
    persons.member_status AS MemberStatusID,
    CASE 
        WHEN persons.member_status = 0 THEN 'N/A'
        WHEN persons.member_status = 1 THEN 'Non-Member'
        WHEN persons.member_status = 2 THEN 'Member'
        WHEN persons.member_status = 4 THEN 'Extra'
        WHEN persons.member_status = 5 THEN 'Ex-Member'
        WHEN persons.member_status = 6 THEN 'Legacy Member'
        ELSE 'Unknown'
    END AS Status,
    persons.persontype AS PersonTypeID,
    CASE 
        WHEN persons.persontype = 0 THEN 'Private'
        WHEN persons.persontype = 1 THEN 'Student'
        WHEN persons.persontype = 2 THEN 'Staff'
        WHEN persons.persontype = 3 THEN 'Friend'
        WHEN persons.persontype = 4 THEN 'Corporate'
        WHEN persons.persontype = 5 THEN 'One Man Corporate'
        WHEN persons.persontype = 6 THEN 'Family'
        WHEN persons.persontype = 7 THEN 'Senior'
        WHEN persons.persontype = 8 THEN 'Guest'
        WHEN persons.persontype = 10 THEN 'External Staff'
        ELSE 'Unknown'
    END AS PersonType,

    -- comment
    ea.txtvalue AS Comment,
    TO_TIMESTAMP(ea.last_edit_time / 1000.0) AS LastEditDate,

    -- employee name
    p.fullname AS EmployeeFullName,
    p.firstname AS EmployeeFirstName,
    p.lastname AS EmployeeLastName,

    -- employee details
    emp.id AS EmployeeID,
    emp.center AS EmployeeCenter,
    emp.personid AS EmployeePersonID, 
    emp.personcenter AS EmployeeCenterID, 

    -- Entry details
    TO_TIMESTAMP(entry_time / 1000.0) AS EntryDate,
    person_change_logs.login_type,
    person_change_logs.change_source

FROM person_change_logs

JOIN employees emp
    ON person_change_logs.employee_id = emp.id 
    AND person_change_logs.employee_center = emp.center

JOIN persons p
    ON emp.personid = p.current_person_id 
    AND emp.personcenter = p.current_person_center

JOIN person_ext_attrs ea
    ON person_change_logs.person_id = ea.personid 
    AND person_change_logs.person_center = ea.personcenter

JOIN persons 
    ON person_change_logs.person_id = persons.current_person_id  
    AND person_change_logs.person_center = persons.current_person_center   

WHERE person_change_logs.change_attribute = '_eClub_Comment' 

    AND ea.name = '_eClub_Comment' 
    AND ea.txtvalue IS NOT NULL 
    AND ea.txtvalue !~ '^\s*$'  -- empty string or whitespace

	AND persons.status = 1  -- Active
    AND persons.member_status = 2  -- Member

ORDER BY person_change_logs.person_id, person_change_logs.entry_time DESC  -- Must start with person_id, and order by entry_time