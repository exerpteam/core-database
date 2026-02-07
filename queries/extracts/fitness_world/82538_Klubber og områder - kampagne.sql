-- This is the version from 2026-02-05
--  
SELECT 
	'A'||a.ID AS AreaID,
	a.NAME AS AreaName,
	CASE
	WHEN c.ID is not null
	THEN 'C'||c.ID 
	ELSE null
	END AS CenterID,
	c.NAME AS CenterName
 
FROM 
	AREAS a
LEFT JOIN
	AREA_CENTERS ac
ON
	a.ID = ac.AREA
LEFT JOIN
	CENTERS c
ON
	ac.CENTER = c.ID
WHERE
	a.ROOT_AREA = 1

ORDER BY
	a.ID,
	c.ID
