-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT center, shortname, blocked, p.name,price, globalid, show_in_sale, show_on_web, mapi_selling_points
FROM products as p LEFT JOIN centers as c ON p.center = c.id
WHERE p.globalid IN ('CREATION_MF_CLUB_PT', 
  'CREATION_MF_FLEX_PT', 
  'CREATION_MF_IBERIA_PT', 
  'CREATION_MF_ONE_PT', 
  'CREATION_MF_PRIME_PT', 
  'CREATION_MF_ZONE_PT', 
  'MF_CLUB_PT', 
  'MF_FLEX_PT', 
  'MF_IBERIA_PT', 
  'MF_ONE_PT', 
  'MF_PRIME_PT', 
  'MF_ZONE_PT', 
    'CREATION_MF_ONE_SP', 
    'CREATION_MF_FLEX_SP',
    'CREATION_MF_PRIME_SP', 
    'CREATION_MF_CLUB_SP',
    'CREATION_MF_IBERIA_SP', 
	'CREATION_MF_ZONE_SP'
    'MF_ONE_SP', 
    'MF_FLEX_SP',
    'MF_PRIME_SP', 
    'MF_CLUB_SP',
    'MF_IBERIA_SP', 
	'MF_ZONE_SP');