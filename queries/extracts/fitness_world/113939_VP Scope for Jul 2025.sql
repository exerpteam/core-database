-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
  c.ID 		AS Center_ID, 
  c.name 	AS Center_name, 
  a.ID 		AS Area_ID, 
  a.NAME 	AS Area_Name, 
  a.PARENT 	AS area_parent 
FROM 
  centers c 
  LEFT JOIN area_centers ac ON c.ID = ac.center 
  LEFT JOIN areas a 		ON ac.area = a.ID 
WHERE 
  a.ROOT_AREA = 569
  AND a.PARENT IS NOT NULL
  AND a.name != 'Lukkede centre' 
  AND a.name != 'Polen' 
  AND a.name != 'Admin' 
ORDER BY 
  a.ID