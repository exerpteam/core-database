-- This is the version from 2026-02-05
--  
SELECT
    ca.CENTER as company_center,
    ca.ID as company_id,
    comp.LASTNAME AS company,
    ca.NAME                                     AS agreement,
    grants.sponsorship_name                     AS sponsor_level,
    DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old',
4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted') AS agreement_state
FROM
     fw.PERSONS comp
JOIN fw.COMPANYAGREEMENTS ca
    ON
       comp.CENTER = ca.CENTER
       AND comp.ID = ca.ID
JOIN fw.privilege_grants grants
    ON
       ca.center = grants.granter_center
       AND ca.id = grants.granter_id
       AND ca.subid = grants.granter_subid
WHERE
    grants.granter_service = 'CompanyAgreement'
AND	ca.state = 1
group by
	ca.CENTER,
    ca.ID,
    comp.LASTNAME,
    ca.NAME,
    grants.sponsorship_name,
    ca.STATE
order by
    ca.center,
    ca.id,
    ca.state