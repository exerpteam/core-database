SELECT
    pcl.*
FROM
    goodlife.person_change_logs pcl
JOIN
    goodlife.persons p
    on p.center = pcl.person_center 
    AND p.id = pcl.person_id            
WHERE
    p.external_id in (:extid) 
AND pcl.change_attribute = 'LAST_NAME'