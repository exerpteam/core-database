SELECT
        p.center || 'p' || p.id AS Exerp_CompanyId,
        pea.txtvalue AS Legacy_CompanyId,
        p.fullname AS Company_Name,
        ca.center || 'p' || ca.id || 'rpt' || ca.subid AS Exerp_CompanyAgreementId,
        ca.name AS CompanyAgreementName,
		CASE WHEN ca.state = 1 THEN 'ATIVO'
			 WHEN ca.state = 2 THEN 'STOP NEW'
			 WHEN ca.state = 3 THEN 'OLD'
			 END AS State
FROM vivagym.persons p
JOIN vivagym.centers c ON p.center = c.id AND c.country = 'PT'
JOIN vivagym.companyagreements ca ON ca.center = p.center AND ca.id = p.id
LEFT JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
WHERE
        p.sex = 'C'
        AND p.status NOT IN (4,5,7,8)
		AND ca.state NOT IN (6)
