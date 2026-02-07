SELECT
        ca.availability as company_agreement_availability,
        c.country as country,
        company.center||'p'||company.id AS company_ID,
        company.LASTNAME AS company_name,
        ca.NAME AS agreement_name,
        CASE ca.STATE WHEN 0 THEN 'Under target' WHEN 1 THEN 'Active' WHEN 2 THEN 'Stop new' WHEN 3 THEN 'Old' WHEN 4 THEN 'Awaiting activation' WHEN 5 THEN 'Blocked' WHEN 6 THEN 'Deleted' END AS company_agreement_state,
        TO_CHAR(ca.STOP_NEW_DATE, 'YYYY-MM-DD') AS agreement_END_DATE,
        ansatte.center||'p'||ansatte.id AS member_ID,
        ansatte.firstname AS member_firstname,
        ansatte.lastname AS member_lastname
FROM
        COMPANYAGREEMENTS ca

JOIN PERSONS company
        ON company.center = ca.center
        AND company.id = ca.id
        AND company.sex = 'C'

LEFT JOIN PRIVILEGE_GRANTS pg
        ON pg.GRANTER_CENTER = ca.CENTER
        AND pg.GRANTER_ID = ca.ID
        AND pg.GRANTER_SUBID = ca.SUBID
        AND pg.GRANTER_SERVICE = 'CompanyAgreement'

JOIN relatives rel
        ON rel.RELATIVECENTER = ca.CENTER
        AND rel.RELATIVEID = ca.ID
        AND rel.RELATIVESUBID = ca.SUBID
        AND rel.RTYPE = 3

JOIN persons ansatte
        ON rel.CENTER = ansatte.CENTER
        AND rel.ID = ansatte.ID
        AND rel.status = 1

JOIN subscriptions s
        ON rel.CENTER = s.OWNER_CENTER
        AND rel.ID = s.owner_id

JOIN subscriptiontypes st
        ON  s.subscriptiontype_center = st.center 
        AND s.subscriptiontype_id = st.id

JOIN centers c
        ON s.owner_center = c.id

WHERE
 ca.state IN (2)   /*agreement stop new*/
        AND s.state IN (2)   /*subscription active*/
        AND c.country IN (:country)

GROUP BY
        ca.availability,
        c.country,
        company.center||'p'||company.id,
        company.LASTNAME,
        ca.NAME,
        ca.STATE,
        ca.STOP_NEW_DATE,
        ansatte.center||'p'||ansatte.id,
        ansatte.firstname,
        ansatte.lastname

ORDER BY
        company.LASTNAME,
        ca.NAME