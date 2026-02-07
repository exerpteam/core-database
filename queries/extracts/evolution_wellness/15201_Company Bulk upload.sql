WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(getCenterTime(c.id),c.id) AS cutdate,
                c.id
        FROM centers c
)
SELECT DISTINCT
        p.center || 'p' || p.id AS CompanyId
        ,p.ssn AS LegacyCompanyId
        ,p.fullname AS CompanyName
        ,ca.name AS companyAgreement
        ,ca.center||'p'||ca.id||'rpt'||ca.subid  AS CompanyAgreementID
        ,ca.stop_new_date AS AgreementEnddate
        ,(CASE ca.state
                WHEN 1 THEN 'ACTIVE'
                WHEN 3 THEN 'OLD'
                WHEN 4 THEN 'CREATED'
                ELSE 'UNKNOWN'
        END) AS company_agreement_state
        ,pg.sponsorship_name 
        ,pp.ref_globalid AS product_global_id
        ,prod.name AS product_name     
FROM evolutionwellness.persons p
JOIN params par ON p.center = par.id
JOIN evolutionwellness.companyagreements ca 
        ON p.center = ca.center AND p.id = ca.id
JOIN privilege_grants pg
        ON pg.granter_center = ca.center
        AND pg.granter_id = ca.id
        AND pg.granter_subid = ca.subid
        AND pg.granter_service = 'CompanyAgreement'
        AND (pg.valid_to IS NULL OR pg.valid_to > par.cutdate)
JOIN evolutionwellness.privilege_sets ps
        ON ps.id = pg.privilege_set
JOIN evolutionwellness.product_privileges pp
        ON pp.privilege_set = ps.id
        AND (pp.valid_to IS NULL OR pp.valid_to > par.cutdate)
JOIN
        evolutionwellness.products prod
        ON prod.globalid = pp.ref_globalid  
        AND prod.ptype = 10    
WHERE
        p.sex = 'C'
        AND 
        p.center||'p'||p.id IN (:CompanyID)
ORDER BY
        1,4