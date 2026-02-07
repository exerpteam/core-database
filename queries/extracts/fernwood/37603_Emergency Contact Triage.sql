SELECT DISTINCT name
FROM person_ext_attrs
WHERE name LIKE '%Emergency%' OR name LIKE '%emergency%' OR name LIKE '%Contact%'
ORDER BY name;