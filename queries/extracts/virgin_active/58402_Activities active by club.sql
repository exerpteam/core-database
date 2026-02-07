SELECT 
	Name,
	CASE 
		WHEN Availability = 'C33' THEN 'Test'
		ELSE 'No'
	END AS Availability
FROM 
	ACTIVITY A 
WHERE 
	Rownum < 100
	