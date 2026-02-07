WITH params AS MATERIALIZED
(
        SELECT
                datetolongc(getCenterTime(c.id),c.id) AS cutdate,
                c.id
        FROM centers c
)
SELECT DISTINCT
        p.center || 'p' || p.id AS CompanyId,
        p.ssn AS LegacyCompanyId,
        p.fullname AS CompanyName,
        ca.name AS comp_agr_name,
        ca.start_date AS comp_agr_startdate,
        ca.stop_new_date AS comp_agr_stopnewdate,
        --ca.state,
        (CASE ca.state
                WHEN 1 THEN 'ACTIVE'
                WHEN 3 THEN 'OLD'
                WHEN 4 THEN 'CREATED'
                ELSE 'UNKNOWN'
        END) AS company_agreement_state,
        longtodatec(pg.valid_from, p.center) AS priv_granter_from,
        longtodatec(pg.valid_to, p.center) AS priv_granter_to,
        pg.sponsorship_name, 
        pg.sponsorship_amount,
        ps.name AS priv_set_name,
        ps.state AS priv_set_state,
        longtodatec(pp.valid_from, p.center) AS product_privilege_valid_from,
        longtodatec(pp.valid_to, p.center) AS product_privilege_valid_to,
        pp.ref_type AS priv_type,
        pp.ref_globalid AS product_global_id,
        prod.name AS product_name,
        pp.price_modification_name,
        pp.price_modification_amount,
        CASE
                WHEN pp.valid_for = 'ASS[A14]' THEN 'Singapore'
                WHEN pp.valid_for = 'ASS[A2]' THEN 'Fitness First'
                WHEN pp.valid_for = 'ASS[A8]' THEN 'Platinum'
                WHEN pp.valid_for = 'ASS[A9]' THEN 'Blue'
                ELSE 'Individual club'
        END AS Scope
,ca.center||'p'||ca.id||'rpt'||ca.subid 
FROM evolutionwellness.persons p
JOIN params par ON p.center = par.id
JOIN evolutionwellness.companyagreements ca 
        ON p.center = ca.center AND p.id = ca.id
LEFT JOIN privilege_grants pg
        ON pg.granter_center = ca.center
        AND pg.granter_id = ca.id
        AND pg.granter_subid = ca.subid
        AND pg.granter_service = 'CompanyAgreement'
        AND (pg.valid_to IS NULL OR pg.valid_to > par.cutdate)
LEFT JOIN evolutionwellness.privilege_sets ps
        ON ps.id = pg.privilege_set
LEFT JOIN evolutionwellness.product_privileges pp
        ON pp.privilege_set = ps.id
        AND (pp.valid_to IS NULL OR pp.valid_to > par.cutdate)
LEFT JOIN
        evolutionwellness.products prod
        ON prod.globalid = pp.ref_globalid      
WHERE
        p.sex = 'C'
        AND p.center IN (:Scope)

ORDER BY
        1,4