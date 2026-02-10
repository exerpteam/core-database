-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS CompanyId,
        p.SSN AS LegacyCompanyId,
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
FROM evolutionwellness.persons p
LEFT JOIN evolutionwellness.companyagreements ca ON p.center = ca.center AND p.id = ca.id
LEFT JOIN evolutionwellness.privilege_grants pg ON pg.granter_center = ca.center AND pg.granter_id = ca.id AND pg.granter_subid = ca.subid AND pg.granter_service = 'CompanyAgreement'
        AND pg.valid_to IS NULL
LEFT JOIN evolutionwellness.privilege_sets ps ON pg.privilege_set = ps.id
WHERE 
        p.center IN (:Scope)
        AND p.sex = 'C'
        AND p.status NOT IN (4,5,7,8)
order by 2