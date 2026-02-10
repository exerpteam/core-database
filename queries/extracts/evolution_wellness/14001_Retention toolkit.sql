-- The extract is extracted from Exerp on 2026-02-08
--  
WITH extended_value AS
        (        
        SELECT
                unnest((xpath('//attribute/possibleValues/possibleValue/@id',xml_element))) AS "id",
                unnest((xpath('//attribute/possibleValues/possibleValue/text()',xml_element))) AS "value"
        FROM
            (
                SELECT
                    s.id,
                    s.scope_type,
                    s.scope_id,
                    unnest(xpath('//attribute',xmlparse(document convert_from(s.mimevalue, 'UTF-8')) )) AS xml_element
                FROM
                    systemproperties s
                WHERE
                    s.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
                AND s.mimetype = 'text/xml') t
        WHERE
            CAST((xpath('//attribute/@id',xml_element))[1] AS text) = 'retentiontoolkit'
        ),
params AS MATERIALIZED
        (
                SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
                FROM
                  centers c
        )           
SELECT DISTINCT
        t.*
FROM
        (
        SELECT 
                p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,ea."value"::VARCHAR AS "Retention tool kit"
                ,empvp.fullname AS "Staff"
                ,empv.center||'emp'||empv.id AS "Staff ID"
                ,longtodatec(pcl2.entry_time,pcl2.person_center) AS "Last edited"
        FROM        
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs pea
                ON pea.personcenter = p.center
                AND pea.personid = p.id
        JOIN
                extended_value ea
                ON ea.id::VARCHAR = pea.txtvalue
        LEFT JOIN
                (
                SELECT MAX(pcl.entry_time) as maxtime, pcl.person_center,pcl.person_id 
                FROM evolutionwellness.person_change_logs pcl 
                WHERE pcl.change_attribute IN ('retentiontoolkit')
                GROUP BY pcl.person_center,pcl.person_id
                )pcl
                ON pcl.person_center = p.center
                AND pcl.person_id = p.id 
        LEFT JOIN
                evolutionwellness.person_change_logs pcl2
                ON pcl.person_center = pcl2.person_center
                AND pcl.person_id = pcl2.person_id
                AND pcl2.entry_time = pcl.maxtime
        LEFT JOIN
                evolutionwellness.employees empv
                ON empv.center = pcl2.employee_center
                AND empv.id = pcl2.employee_id 
        LEFT JOIN
                evolutionwellness.persons empvp
                ON empvp.center = empv.personcenter
                AND empvp.id = empv.personid  
        JOIN
                params 
                ON params.center_id = p.center                                  
        WHERE
                pea.name = 'retentiontoolkit' 
                AND pea.txtvalue IS NOT NULL
                AND p.center IN (:Scope)
                AND pcl.maxtime BETWEEN params.FromDate AND params.ToDate   
        )t                