-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(getCenterTime(c.id),c.id) AS cutdate,
                c.id
        FROM centers c
),
active_member_count AS
(
SELECT
        cag.center
        ,cag.id
        ,cag.subid
        ,count(*) AS CountOfMembers
FROM
        evolutionwellness.persons p
JOIN 
        evolutionwellness.relatives relcomagr 
        ON relcomagr.center = p.center 
        AND relcomagr.id = p.id 
        AND relcomagr.rtype = 3
        AND relcomagr.status = 1
JOIN 
        evolutionwellness.companyagreements cag 
        ON relcomagr.relativecenter = cag.center 
        AND relcomagr.relativeid = cag.id 
        AND relcomagr.relativesubid = cag.subid
GROUP BY
        cag.center
        ,cag.id
        ,cag.subid
),
New_joiner_count AS
(
SELECT
        cag.center
        ,cag.id
        ,cag.subid
        ,count(*) as CountOfJoiners
FROM
        evolutionwellness.persons p
JOIN 
        evolutionwellness.relatives relcomagr 
        ON relcomagr.center = p.center 
        AND relcomagr.id = p.id 
        AND relcomagr.rtype = 3
        AND relcomagr.status = 1
JOIN 
        evolutionwellness.companyagreements cag 
        ON relcomagr.relativecenter = cag.center 
        AND relcomagr.relativeid = cag.id 
        AND relcomagr.relativesubid = cag.subid
JOIN
        evolutionwellness.subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id
JOIN
        params
        ON params.id = p.center
WHERE
        EXTRACT(YEAR FROM longtodatec(s.creation_time,s.center))||'-'||EXTRACT(MONTH FROM longtodatec(s.creation_time,s.center)) = EXTRACT(YEAR FROM longtodatec(params.cutdate ,params.id))||'-'||EXTRACT(MONTH FROM longtodatec(params.cutdate ,params.id))
GROUP BY
        cag.center
        ,cag.id
        ,cag.subid        
)                          
SELECT DISTINCT
        p.center ||'p'||p.id AS "Company PNumber"
        ,p.fullname AS "Company Name"
        ,ca.name as "Company Agreement"
        ,ca.start_date
        ,ca.stop_new_date
        ,pg.sponsorship_name AS "Subsidy Type"
        ,amc.CountOfMembers AS "Count of Active Members"
        ,njc.CountOfJoiners AS "Count Of Current Month Joiners"
FROM
        evolutionwellness.persons p
JOIN
        params 
        ON params.id = p.center        
JOIN
        evolutionwellness.companyagreements ca
        ON ca.center = p.center
        AND ca.id = p.id
        AND (ca.stop_new_date IS NULL OR ca.stop_new_date > current_date)
LEFT JOIN privilege_grants pg
        ON pg.granter_center = ca.center
        AND pg.granter_id = ca.id
        AND pg.granter_subid = ca.subid
        AND pg.granter_service = 'CompanyAgreement'
        AND (pg.valid_to IS NULL OR pg.valid_to > params.cutdate)  
LEFT JOIN
        active_member_count amc
        ON amc.center = ca.center
        AND amc.id = ca.id
        AND amc.subid = ca.subid
LEFT JOIN
        New_joiner_count njc
        ON njc.center = ca.center
        AND njc.id = ca.id
        AND njc.subid = ca.subid  
WHERE
        (ca.stop_new_date - current_date) BETWEEN 0 AND :Days
        AND 
        p.center IN (:Scope)                       
                        