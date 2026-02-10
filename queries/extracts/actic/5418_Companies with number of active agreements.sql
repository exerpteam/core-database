-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Exerp
* Purpose: List companies with count of active agreements.
*/
SELECT
    ca.CENTER||'p'||ca.ID AS company_id,
    comp.LASTNAME AS company,
    comp.address1,
    comp.zipcode,
	ca.AVAILABILITY AS CA_AVAILABLE,
    COUNT(DISTINCT(grants.granter_subid)) AS count_active
FROM
     PERSONS comp
JOIN COMPANYAGREEMENTS ca
    ON
       comp.CENTER = ca.CENTER
       AND comp.ID = ca.ID
JOIN privilege_grants grants
    ON
       ca.center = grants.granter_center
       AND ca.id = grants.granter_id
       AND ca.subid = grants.granter_subid
WHERE
    grants.granter_service = 'CompanyAgreement'
    AND ca.state = 1  /*2 = 'stop new', 1 = 'active'*/
    AND ca.center IN (:scope)
GROUP BY
    ca.CENTER,
    ca.ID,
    comp.LASTNAME,
    comp.address1,
    comp.zipcode,
	ca.AVAILABILITY
ORDER BY
    ca.center,
    ca.id
