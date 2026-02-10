-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	c.Name AS "Club",
	longtodatec(je.creation_time,p.center) AS "Created date",
	TO_CHAR(longtodateC(je.creation_time,p.center),'HH24:MI') AS "Creation Time",
	je.name AS "Subject", 
	--je.creatorcenter||'p'||je.creatorId AS "Created By",
	emp.FirstName || emp.LastName AS "Created By",
	p.center||'p'||p.id  AS "Person Id",
	COALESCE(p.External_Id, trf.External_Id) AS "Member Id",
	p.FirstName AS "First Name",
	p.Lastname AS "Last Name",
	je.text AS "Details"
	--je.state AS "Status" 
FROM
   Persons p
JOIN 
	evolutionwellness.journalentries je 
	ON je.person_center = p.center AND je.person_id = p.id
JOIN persons emp
	ON je.creatorcenter = emp.center
	AND je.creatorId = emp.id
JOIN centers c
	ON c.id = p.center
LEFT JOIN Persons trf 
	ON p.transfers_current_prs_center = trf.center
	AND p.transfers_current_prs_id = trf.id
WHERE
        p.center IN (:Scope)
	AND p.sex NOT IN ('C')
	AND je.name = 'Guest Waiver'
	AND longtodatec(je.creation_time,p.center) BETWEEN (:From) AND (CAST(:To AS DATE) + INTERVAL '1 day')
ORDER BY 1,2,3