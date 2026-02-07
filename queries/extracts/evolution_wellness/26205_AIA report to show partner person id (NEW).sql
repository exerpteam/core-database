SELECT 
        t."Member Full Name"
        ,t."Member ID"
        ,t."External ID"
        ,MAX(t."Member date joined corporate") AS "Last Update"
        ,t."Partner PersonID"
        ,t."AIA Vitality Category"
        ,t."Activation Status"
FROM
        (
        SELECT
                p.fullname AS "Member Full Name"
                ,p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
                ,aia.txtvalue AS "Partner PersonID"
                ,cat.txtvalue AS "AIA Vitality Category"
                ,aiart.txtvalue AS "Activation Status"
                ,1 as type
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs aia
                ON aia.personcenter = p.center
                AND aia.personid = p.id
                AND aia.name IN ('VitalityCheckinID', 'VitalityCheckin',  'VitalityCheckinMY', 'VitalityCheckinTH', '_eClub_PBLookupPartnerPersonId')   
                AND aia.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs aiart
                ON aiart.personcenter = p.center
                AND aiart.personid = p.id
                AND aiart.name IN ( 'AIAStatus')     
                AND aiart.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs cat
                ON cat.personcenter = p.center
                AND cat.personid = p.id
                AND cat.name IN ('AIAActivationPartnerSubCodesID', 'AIAActivationPartnerSubCodesSG', 'AIAActivationPartnerSubCodesMY' , 'AIAActivationPartnerSubCodesTH' )    
                AND cat.txtvalue IS NOT NULL                 
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center               
        WHERE
                p.center IN (:Scope)
                AND
                aia.txtvalue NOT like '1%'                             
        UNION ALL
        SELECT
                p.fullname AS "Member Full Name"
                ,p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
                ,aia.txtvalue AS "Partner PersonID"
                ,cat.txtvalue AS "AIA Vitality Category"
                ,aiart.txtvalue AS "Activation Status"
                ,2 as type
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs aia
                ON aia.personcenter = p.center
                AND aia.personid = p.id
                AND aia.name = 'VitalityCheckinID' --Indonesia    
                AND aia.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs aiart
                ON aiart.personcenter = p.center
                AND aiart.personid = p.id
                AND aiart.name = 'AIAStatus'     
                AND aiart.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs cat
                ON cat.personcenter = p.center
                AND cat.personid = p.id
                AND cat.name = 'AIAActivationPartnerSubCodesID'                  
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center               
        WHERE
                p.center IN (:Scope)  
                AND
                aia.txtvalue NOT like '1%'       
        UNION ALL
        SELECT
                p.fullname AS "Member Full Name"
                ,p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
                ,aia.txtvalue AS "Partner PersonID"
                ,cat.txtvalue AS "AIA Vitality Category"
                ,aiart.txtvalue AS "Activation Status"
                ,3 as type
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs aia
                ON aia.personcenter = p.center
                AND aia.personid = p.id
                AND aia.name = 'VitalityCheckin' --Singapore    
                AND aia.txtvalue IS NOT NULL
        LEFT JOIN
                evolutionwellness.person_ext_attrs aiart
                ON aiart.personcenter = p.center
                AND aiart.personid = p.id
                AND aiart.name = 'AIAStatus'     
                AND aiart.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs cat
                ON cat.personcenter = p.center
                AND cat.personid = p.id
                AND cat.name = 'AIAActivationPartnerSubCodesSG'                   
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center               
        WHERE
                p.center IN (:Scope)  
                AND
                aia.txtvalue NOT like '1%' 
        UNION ALL
        SELECT
                p.fullname AS "Member Full Name"
                ,p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
                ,aia.txtvalue AS "Partner PersonID"
                ,cat.txtvalue AS "AIA Vitality Category"
                ,aiart.txtvalue AS "Activation Status"
                ,4 as type
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs aia
                ON aia.personcenter = p.center
                AND aia.personid = p.id
                AND aia.name = 'VitalityCheckinMY' --Malaysia    
                AND aia.txtvalue IS NOT NULL
        LEFT JOIN
                evolutionwellness.person_ext_attrs aiart
                ON aiart.personcenter = p.center
                AND aiart.personid = p.id
                AND aiart.name = 'AIAStatus'     
                AND aiart.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs cat
                ON cat.personcenter = p.center
                AND cat.personid = p.id
                AND cat.name = 'AIAActivationPartnerSubCodesMY'                     
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center               
        WHERE
                p.center IN (:Scope) 
                AND
                aia.txtvalue NOT like '1%' 
        UNION ALL
        SELECT
                p.fullname AS "Member Full Name"
                ,p.center||'p'||p.id AS "Member ID"
                ,p.external_id AS "External ID"
                ,longtodatec(aia.last_edit_time,aia.personcenter) AS "Member date joined corporate"
                ,aia.txtvalue AS "Partner PersonID"
                ,cat.txtvalue AS "AIA Vitality Category"
                ,aiart.txtvalue AS "Activation Status"
                ,5 as type
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.person_ext_attrs aia
                ON aia.personcenter = p.center
                AND aia.personid = p.id
                AND aia.name = 'VitalityCheckinTH' --Thailand    
                AND aia.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs aiart
                ON aiart.personcenter = p.center
                AND aiart.personid = p.id
                AND aiart.name = 'AIAStatus'     
                AND aiart.txtvalue IS NOT NULL 
        LEFT JOIN
                evolutionwellness.person_ext_attrs cat
                ON cat.personcenter = p.center
                AND cat.personid = p.id
                AND cat.name = 'AIAActivationPartnerSubCodesTH'                    
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center               
        WHERE
                p.center IN (:Scope)     
                AND
                aia.txtvalue NOT like '1%'            
        )t
WHERE
        t."External ID" IS NOT NULL               
GROUP BY 
        t."Member Full Name"
        ,t."Member ID"
        ,t."External ID"
        ,t."Partner PersonID"
        ,t."AIA Vitality Category"
        ,t."Activation Status" 