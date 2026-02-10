-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        staff_group_ranking AS
        (
                SELECT
                        CASE
                                WHEN sg.name IN ('New Fitness Instructor','Personal Trainer') THEN 1
                                WHEN sg.name IN ('Advanced Personal Trainer') THEN 2
                                WHEN sg.name IN ('Elite Personal Trainer') THEN 3
                                WHEN sg.name IN ('Master Personal Trainer','Certified Fitness Coach') THEN 4
                        END AS ranking
                        ,sg.id
                FROM 
                        staff_groups sg    
                WHERE 
                        sg.name in ('New Fitness Instructor','Personal Trainer','Advanced Personal Trainer','Elite Personal Trainer','Master Personal Trainer','Certified Fitness Coach')
        ),           
        max_ranking AS
        (
                SELECT
                        p.external_id
                        ,p.center
                        ,max(sgr.ranking) as max_sgr
                FROM
                        persons p
                JOIN
                        person_staff_groups psg
                        ON psg.person_center = p.center
                        AND psg.person_id = p.id
                JOIN
                        staff_groups sg
                        ON sg.id = psg.staff_group_id
                JOIN
                        staff_group_ranking sgr
                        ON sgr.id = sg.id
                GROUP BY
                        p.external_id
                        ,p.center                         
        )
SELECT DISTINCT
        p.external_id AS "External ID"
        ,p.center AS "Center ID"
        ,mr.max_sgr AS "Grade"
FROM
        persons p
JOIN
        person_staff_groups psg
        ON psg.person_center = p.center
        AND psg.person_id = p.id
JOIN
        staff_groups sg
        ON sg.id = psg.staff_group_id
JOIN
        staff_group_ranking sgr
        ON sgr.id = sg.id
JOIN
        max_ranking mr
        ON mr.max_sgr = sgr.ranking
        AND p.external_id = mr.external_id                                                
WHERE
        p.external_id IN (:External_ID)