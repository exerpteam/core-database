-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	c.id as CenterID, 
	c.shortname,
	c.name,
	c.manager_center || 'p' || c.manager_id AS ManagerID,
	pm.firstname AS ManagerFirstName,
	pm.lastname AS ManagerLastName,	
	c.asst_manager_center || 'p' || c.asst_manager_id AS AsstManagerId,
	pam.firstname as AsstManagerFirstName,
	pam.lastname AS AsstManagerLastName,
	cea.txt_value as FitnessManagerID,
	pf.firstname AS FitnessManagerFirstName,
	pf.lastname AS FitnessManagerLastName
FROM centers c
 JOIN center_ext_attrs cea
	ON cea.center_id = c.id
	AND cea.name='FITMANAGER'
LEFT JOIN persons pm
	ON pm.center = c.manager_center and pm.id = c.manager_id
LEFT JOIN persons pam
	ON pam.center = c.asst_manager_center and pam.id = c.asst_manager_id
LEFT JOIN persons pf
	ON pf.center || 'p' || pf.id = cea.txt_value
	