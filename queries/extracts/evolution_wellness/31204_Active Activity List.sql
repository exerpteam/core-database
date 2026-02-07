WITH RECURSIVE centers_in_area AS (
    SELECT a.id, a.parent, ARRAY[a.id] AS chain_of_command_ids, 2 AS level
    FROM areas a
    WHERE a.types LIKE '%system%' AND a.parent IS NULL
    UNION ALL
    SELECT a.id, a.parent, array_append(cin.chain_of_command_ids, a.id), cin.level + 1
    FROM areas a
    JOIN centers_in_area cin ON cin.id = a.parent
),
areas_total AS (
    SELECT
        cin.id AS id,
        unnest(array_remove(array_agg(b.id), NULL)) AS sub_areas
    FROM centers_in_area cin
    LEFT JOIN centers_in_area b
      ON cin.id = ANY(b.chain_of_command_ids)
     AND cin.level <= b.level
    GROUP BY 1
),
tree_shape AS (
    SELECT 'A' AS scope_type, at.id AS scope_id, ac.center AS center_id
    FROM areas_total at
    LEFT JOIN area_centers ac ON ac.area = at.sub_areas
    JOIN centers c ON ac.center = c.id
),
activity_availability_unnested AS (
    SELECT 
        a.id,
        LEFT(av.value,1) AS availability_scope_type,
        CAST(SUBSTRING(av.value FROM 2) AS INT) AS availability_scope_id
    FROM evolutionwellness.activity a
    CROSS JOIN LATERAL unnest(string_to_array(a.availability, ',')) AS av(value)
    WHERE a.state = 'ACTIVE' AND a.top_node_id IS NULL AND a.availability != ''
),
availability AS (
    SELECT aau.id, ts.center_id
    FROM activity_availability_unnested aau
    JOIN tree_shape ts
      ON aau.availability_scope_type = ts.scope_type
     AND aau.availability_scope_id = ts.scope_id
    WHERE aau.availability_scope_type = 'A'
    UNION ALL
    SELECT aau.id, aau.availability_scope_id AS center_id
    FROM activity_availability_unnested aau
    WHERE aau.availability_scope_type = 'C'
)
SELECT DISTINCT
    CASE 
        WHEN areas.id = 4 THEN 'Celebrity Fitness'
        WHEN areas.id IN (15,22,23) THEN 'Fitness First'
        WHEN areas.id IN (7,30) THEN 'Celebrity Fitness'
        WHEN areas.id IN (17,32,33) THEN 'Fitness First'
        WHEN areas.id IN (6,26) THEN 'Celebrity Fitness'
        WHEN areas.id IN (21,29,27,28,37) THEN 'Fitness First'
        WHEN areas.id IN (18,24,25) THEN 'Fitness First'
        WHEN areas.id IN (2,8,9) THEN 'Fitness First'
        ELSE 'Unknown'
    END AS "Scope Level",
    c.country AS "Country",
    a.id AS "Activity ID",
    a.name AS "Activity Name"
FROM evolutionwellness.activity a
JOIN availability av ON av.id = a.id
JOIN centers c ON c.id = av.center_id
JOIN area_centers ac ON ac.center = c.id
JOIN areas ON areas.id = ac.area AND areas.root_area = 1
WHERE a.state = 'ACTIVE'
	AND a.activity_type =2
  AND areas.id IN (2,4,6,7,8,9,15,17,18,21,22,23,24,25,26,27,28,29,30,32,33,37)
ORDER BY "Scope Level", "Country", "Activity ID";
