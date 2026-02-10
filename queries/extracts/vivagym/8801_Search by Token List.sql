-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS PersonId,
        p.external_id,
        p.firstname,
        p.lastname,
        pea.txtvalue AS email,
        pag.clearinghouse_ref
FROM vivagym.persons p
JOIN vivagym.centers c ON p.center = c.id AND c.country = 'PT'
JOIN vivagym.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN vivagym.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN vivagym.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
LEFT JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_Email'
WHERE
        pag.clearinghouse_ref IN (:token)