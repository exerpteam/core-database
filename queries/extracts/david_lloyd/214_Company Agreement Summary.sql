-- This is the version from 2026-02-05
--  
SELECT
        p.center || 'p' || p.id AS ExerpId,
        p.SSN AS CompanyId,
        p.fullname,
        ca.center || 'p' || ca.id || 'rpt' || ca.subid AS company_agreement_id,
        (CASE ca.state 
                WHEN 1 THEN 'ACTIVE'
                WHEN 2 THEN 'STOP_NEW'
                WHEN 3 THEN 'OLD'
                WHEN 4 THEN 'CREATED'
                WHEN 6 THEN 'DELETED'
        END) AS company_agreement_state,
        ca.name AS company_agreement_name,
        ps.name AS privilegeset_name
FROM persons p
LEFT JOIN companyagreements ca ON p.center = ca.center AND p.id = ca.id
LEFT JOIN privilege_grants pg ON pg.granter_center = ca.center AND pg.granter_id = ca.id AND pg.granter_subid = ca.subid AND pg.granter_service = 'CompanyAgreement'
        AND pg.valid_to IS NULL
LEFT JOIN privilege_sets ps ON pg.privilege_set = ps.id
WHERE 
        p.center IN (:Scope)
        AND p.sex = 'C'
        AND p.status NOT IN (4,5,7,8)
order by 2