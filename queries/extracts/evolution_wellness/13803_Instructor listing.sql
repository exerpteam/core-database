-- The extract is extracted from Exerp on 2026-02-08
--  
WITH RECURSIVE centers_in_area AS
        (
                SELECT
                        a.id,
                        a.parent,
                        ARRAY[id] AS chain_of_command_ids,
                        2         AS level
                FROM areas a
                WHERE
                        a.types LIKE '%system%'
                        AND a.parent IS NULL
                UNION ALL
                SELECT
                        a.id,
                        a.parent,
                        array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
                        cin.level + 1                                AS level
                FROM areas a
                JOIN centers_in_area cin ON cin.id = a.parent
        ),
        areas_total AS
        (
                SELECT
                        cin.id AS ID,
                        cin.level,
                        unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
                FROM centers_in_area cin
                LEFT JOIN centers_in_area AS b -- join provides subordinates
                        ON cin.id = ANY (b.chain_of_command_ids)
                        AND cin.level <= b.level
                GROUP BY
                        1,2
        ),
        tree_shape AS
        (
                SELECT
                        'A'               AS SCOPE_TYPE,
                        areas_total.ID    AS SCOPE_ID,
                        ac.CENTER         AS CENTER_ID,
                        areas_total.level AS level_scope
                FROM areas_total
                LEFT JOIN area_centers ac
                        ON ac.area = areas_total.sub_areas
                JOIN centers c
                        ON ac.CENTER = c.id
        ),
        system_scope AS
        (
                SELECT
                        *
                FROM centers
        ),
        PTHD AS
        (
        SELECT 
                p.center
                ,p.id
                ,PTHD.text_value AS "PT – Hired Date"
        FROM 
                evolutionwellness.persons p   
        JOIN
                evolutionwellness.custom_attributes PTHD
                ON PTHD.ref_id = p.id
                AND PTHD.ref_center_id = p.center
                AND PTHD.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTHD
                ON cacPTHD.id = PTHD.custom_attribute_config_id
                AND cacPTHD.external_id = 'PTHD'
        ),
        PTG AS
        (                 
        SELECT 
                p.center
                ,p.id
                ,cavPTG.value AS "PT – Grade"
        FROM 
                evolutionwellness.persons p   
        JOIN
                evolutionwellness.custom_attributes PTG
                ON PTG.ref_id = p.id
                AND PTG.ref_center_id = p.center
                AND PTG.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTG
                ON cacPTG.id = PTG.custom_attribute_config_id
                AND cacPTG.external_id = 'PTG' 
        JOIN
                evolutionwellness.custom_attribute_config_values cavPTG
                ON cavPTG.id = PTG.custom_attribute_config_value_id
        ),
        PTCT AS
        (
        SELECT 
                p.center
                ,p.id
                ,cavPTCT.value AS "PT – Contract Type"
        FROM 
                evolutionwellness.persons p                               
        JOIN
                evolutionwellness.custom_attributes PTCT
                ON PTCT.ref_id = p.id
                AND PTCT.ref_center_id = p.center
                AND PTCT.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTCT
                ON cacPTCT.id = PTCT.custom_attribute_config_id
                AND cacPTCT.external_id = 'PTCT'   
        JOIN
                evolutionwellness.custom_attribute_config_values cavPTCT
                ON cavPTCT.id = PTCT.custom_attribute_config_value_id 
        ),
        PTET AS
        (
        SELECT 
                p.center
                ,p.id
                ,cavPTET.value AS "PT – Employee Type"
        FROM 
                evolutionwellness.persons p                             
        JOIN
                evolutionwellness.custom_attributes PTET
                ON PTET.ref_id = p.id
                AND PTET.ref_center_id = p.center
                AND PTET.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTET
                ON cacPTET.id = PTET.custom_attribute_config_id
                AND cacPTET.external_id = 'PTET'    
        JOIN
                evolutionwellness.custom_attribute_config_values cavPTET
                ON cavPTET.id = PTET.custom_attribute_config_value_id
        ),
        PTRD AS
        ( 
        SELECT 
                p.center
                ,p.id
                ,PTRD.text_value AS "PT – Resigned Date"
        FROM 
                evolutionwellness.persons p                            
        JOIN
                evolutionwellness.custom_attributes PTRD
                ON PTRD.ref_id = p.id
                AND PTRD.ref_center_id = p.center
                AND PTRD.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacPTRD
                ON cacPTRD.id = PTRD.custom_attribute_config_id
                AND cacPTRD.external_id = 'PTRD' 
        ),
        GXRCT AS
        ( 
        SELECT 
                p.center
                ,p.id
                ,cavGXRCT.value AS "GX – Rate card type"
        FROM 
                evolutionwellness.persons p                      
        JOIN
                evolutionwellness.custom_attributes GXRCT
                ON GXRCT.ref_id = p.id
                AND GXRCT.ref_center_id = p.center
                AND GXRCT.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXRCT
                ON cacGXRCT.id = GXRCT.custom_attribute_config_id
                AND cacGXRCT.external_id = 'GXRCT'
        JOIN
                evolutionwellness.custom_attribute_config_values cavGXRCT
                ON cavGXRCT.id = GXRCT.custom_attribute_config_value_id 
        ),
        GXD AS
        (
        SELECT 
                p.center
                ,p.id
                ,GXD.text_value AS "GX – Date"
        FROM 
                evolutionwellness.persons p                                  
        JOIN
                evolutionwellness.custom_attributes GXD
                ON GXD.ref_id = p.id
                AND GXD.ref_center_id = p.center
                AND GXD.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXD
                ON cacGXD.id = GXD.custom_attribute_config_id
                AND cacGXD.external_id = 'GXD'
        ),
        GXCT AS
        (                
        SELECT 
                p.center
                ,p.id
                ,cavGXCT.value AS "Contract Type"
        FROM 
                evolutionwellness.persons p                         
        JOIN
                evolutionwellness.custom_attributes GXCT
                ON GXCT.ref_id = p.id
                AND GXCT.ref_center_id = p.center
                AND GXCT.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXCT
                ON cacGXCT.id = GXCT.custom_attribute_config_id
                AND cacGXCT.external_id = 'GXCT' 
        JOIN
                evolutionwellness.custom_attribute_config_values cavGXCT
                ON cavGXCT.id = GXCT.custom_attribute_config_value_id  
        ),
        GXET AS
        (        
        SELECT 
                p.center
                ,p.id
                ,cavGXET.value AS "Employee Type"
        FROM 
                evolutionwellness.persons p             
        JOIN
                evolutionwellness.custom_attributes GXET
                ON GXET.ref_id = p.id
                AND GXET.ref_center_id = p.center
                AND GXET.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXET
                ON cacGXET.id = GXET.custom_attribute_config_id
                AND cacGXET.external_id = 'GXET'      
        JOIN
                evolutionwellness.custom_attribute_config_values cavGXET
                ON cavGXET.id = GXET.custom_attribute_config_value_id  
        ),
        GXBS AS 
        (        
        SELECT 
                p.center
                ,p.id
                ,GXBS.text_value AS "GX – Base Salary"
        FROM 
                evolutionwellness.persons p        
        JOIN
                evolutionwellness.custom_attributes GXBS
                ON GXBS.ref_id = p.id
                AND GXBS.ref_center_id = p.center
                AND GXBS.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXBS
                ON cacGXBS.id = GXBS.custom_attribute_config_id
                AND cacGXBS.external_id = 'GXBS'
        ),
        GXQH AS
        (
        SELECT 
                p.center
                ,p.id
                ,GXQH.text_value AS "GX – Quota Hours"
        FROM 
                evolutionwellness.persons p                            
        JOIN
                evolutionwellness.custom_attributes GXQH
                ON GXQH.ref_id = p.id
                AND GXQH.ref_center_id = p.center
                AND GXQH.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXQH
                ON cacGXQH.id = GXQH.custom_attribute_config_id
                AND cacGXQH.external_id = 'GXQH'
        ),
        GXTH AS
        (
        SELECT 
                p.center
                ,p.id
                ,GXTH.text_value AS "GX - Threshold Hours"
        FROM 
                evolutionwellness.persons p                  
        JOIN
                evolutionwellness.custom_attributes GXTH
                ON GXTH.ref_id = p.id
                AND GXTH.ref_center_id = p.center
                AND GXTH.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXTH
                ON cacGXTH.id = GXTH.custom_attribute_config_id
                AND cacGXTH.external_id = 'GXTH' 
        ),
        GXFLR AS
        (
        SELECT 
                p.center
                ,p.id
                ,GXFLR.text_value AS "GX - Freelance Rate"
        FROM 
                evolutionwellness.persons p           
        JOIN
                evolutionwellness.custom_attributes GXFLR
                ON GXFLR.ref_id = p.id
                AND GXFLR.ref_center_id = p.center
                AND GXFLR.ref_type = 'STAFF'
        JOIN
                evolutionwellness.custom_attribute_configs cacGXFLR
                ON cacGXFLR.id = GXFLR.custom_attribute_config_id
                AND cacGXFLR.external_id = 'GXFLR'
        )  
SELECT DISTINCT
		--From Date	To Date	Contract Type	Employee Type	RateCard Status	Certified Program	Certificate Start Date	Program Name

        c.name as "Home Club Name"
        ,pclsp.new_value AS "Employee ID"
        ,emp.center||'emp'||emp.id AS "Login ID"
        ,p.center||'p'||p.id as "Person ID"
        ,p.nickname AS Fullname
        ,p.fullname as NickName
        ,sg.name AS StaffGroup
        ,psg.salary
        ,PTHD."PT – Hired Date" AS "PT – Hired Date"
        ,PTG."PT – Grade" AS "PT – Grade" 
        ,PTCT."PT – Contract Type" AS "PT – Contract Type"
        ,PTET."PT – Employee Type" AS "PT – Employee Type"
        ,PTRD."PT – Resigned Date" AS "PT – Resigned Date"
        ,GXRCT."GX – Rate card type" AS "GX – Rate card type"
        ,GXD."GX – Date" AS "GX – Date"
        ,GXCT."Contract Type" AS "Contract Type"
        ,GXET."Employee Type" AS "Employee Type"
        ,GXBS."GX – Base Salary" AS "GX – Base Salary"
        ,GXQH."GX – Quota Hours" AS "GX – Quota Hours"
        ,GXTH."GX - Threshold Hours" AS "GX - Threshold Hours"
        ,GXFLR."GX - Freelance Rate" AS "GX - Freelance Rate"
FROM 
        evolutionwellness.persons p 
LEFT JOIN
        evolutionwellness.employees emp
        ON emp.personcenter = p.center
        AND emp.personid = p.id
        AND emp.blocked IS FALSE           
LEFT JOIN
        evolutionwellness.person_staff_groups psg
        ON psg.person_center = p.center
        AND psg.person_id = p.id
LEFT JOIN
        evolutionwellness.staff_groups sg
        ON sg.id = psg.staff_group_id   
LEFT JOIN
        evolutionwellness.areas a2
        ON a2.id = psg.scope_id
        AND psg.scope_type = 'A' 
LEFT JOIN
        evolutionwellness.centers c2
        ON c2.id = psg.scope_id
        AND psg.scope_type = 'C' 
JOIN
        evolutionwellness.centers c
        ON p.center = c.id    
LEFT JOIN
        person_change_logs pclsp
        ON pclsp.person_center = p.center
        AND pclsp.person_id = p.id
        AND pclsp.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'  
LEFT JOIN
        PTHD
        ON PTHD.id = p.id
        AND PTHD.center = p.center
LEFT JOIN
        PTG
        ON PTG.id = p.id
        AND PTG.center = p.center       
LEFT JOIN
        PTCT
        ON PTCT.id = p.id
        AND PTCT.center = p.center       
LEFT JOIN
        PTET
        ON PTET.id = p.id
        AND PTET.center = p.center         
LEFT JOIN
        PTRD
        ON PTRD.id = p.id
        AND PTRD.center = p.center
LEFT JOIN
        GXRCT
        ON GXRCT.id = p.id
        AND GXRCT.center = p.center               
LEFT JOIN
        GXD
        ON GXD.id = p.id
        AND GXD.center = p.center 
LEFT JOIN
        GXCT
        ON GXCT.id = p.id
        AND GXCT.center = p.center         
LEFT JOIN
        GXET
        ON GXET.id = p.id
        AND GXET.center = p.center   
LEFT JOIN
        GXBS
        ON GXBS.id = p.id
        AND GXBS.center = p.center
LEFT JOIN
        GXQH
        ON GXQH.id = p.id
        AND GXQH.center = p.center
LEFT JOIN
        GXTH
        ON GXTH.id = p.id
        AND GXTH.center = p.center
LEFT JOIN
        GXFLR
        ON GXFLR.id = p.id
        AND GXFLR.center = p.center                                                                                                                                           
WHERE
        p.persontype = 2
        AND
        p.center IN (:Scope)