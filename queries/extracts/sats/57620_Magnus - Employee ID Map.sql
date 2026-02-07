SELECT
	e.center||'emp'||e.id AS EMPLOYEE_ID,
	p.PERSON_ID
FROM sats.EMPLOYEES e
	JOIN sats.BI_PERSONS p ON e.personcenter = p.home_center_id AND e.personid = p.home_center_person_id
--where e.center = 500 and e.id = 52199
