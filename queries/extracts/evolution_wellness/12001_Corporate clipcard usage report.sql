WITH params AS
            (
                SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                    c.id AS CENTER_ID,
                    CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'),'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                    centers c
            )   
SELECT
        p.fullname AS "Company Name"
        ,p.center || 'p' ||p.id AS "Company ID"
        ,prod.name
        ,longtodatec(ccu.time,ccu.card_center) AS "Usage Date"     
        ,ccu.description AS "Activity"
        ,emp.fullname AS "Employee Name"
        ,emp.external_id AS "Employee Membership Number"
        ,uc.name AS "Club Accessed"
        ,(CAST(longtodatec(ccu.time,ccu.card_center) AS Time)) AS "Time accessed"           
FROM
        evolutionwellness.clipcards cc
JOIN
        card_clip_usages ccu 
        ON cc.center = ccu.card_center 
        AND cc.id = ccu.card_id 
        AND cc.subid = ccu.card_subid 
JOIN
        evolutionwellness.persons p
        ON p.center = cc.owner_center
        AND p.id = cc.owner_id  
JOIN
        evolutionwellness.products prod
        ON prod.center = cc.center
        AND prod.id = cc.id    
JOIN
        evolutionwellness.privilege_usages pu
        ON pu.source_center = ccu.card_center
        AND pu.source_id = ccu.card_id
        AND pu.source_subid = ccu.card_subid
        AND ccu.ref = pu.id
JOIN
        evolutionwellness.persons emp
        ON emp.center = pu.person_center
        AND emp.id = pu.person_id
JOIN
        params
        ON params.center_id = cc.center  
JOIN
        evolutionwellness.centers uc
        ON uc.id = pu.target_center                                             
WHERE
        cc.owner_center||'p'||cc.owner_id IN (:CompanyID)
        AND
        ccu.state != 'CANCELLED'  
        AND
        ccu.time BETWEEN params.FromDate AND params.ToDate      