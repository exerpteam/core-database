-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
         p.center||'p'||p.id AS PersonID
         ,ar.balance
FROM evolutionwellness.persons p
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND pag.clearinghouse = 1001
        AND ar.balance < 0