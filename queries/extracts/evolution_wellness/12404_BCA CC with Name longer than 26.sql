-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS personid
FROM evolutionwellness.persons p
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN evolutionwellness.clearinghouses ch ON pag.clearinghouse = ch.id
WHERE
        ar.ar_type = 4
        AND ch.id IN (1202,1402, 1201)
        AND pag.name IS NOT NULL
        AND length(pag.name) > 26
        AND pag.state IN (1,2,4)