-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        mem.center ||'p'|| mem.id AS "Person ID"
        ,mem.fullname AS "Person Full Name"
        ,ca.center||'p'||ca.id||'rpt'||ca.subid AS "Company Agreement ID"
        ,corp.center||'p'||corp.id AS "Cpmpany ID"
        ,corp.fullname AS "Company Name"
FROM
        leejam.companyagreements ca
JOIN
        leejam.relatives rel
        ON rel.relativecenter = ca.center
        AND rel.relativeid = ca.id
        AND rel.relativesubid = ca.subid
        AND rel.status < 3 -- Relationship must be active
        AND rel.rtype = 3
JOIN
        leejam.persons mem
        ON mem.center = rel.center
        AND mem.id = rel.id
        AND mem.persontype = 4 --Person must be type CORPORATE
JOIN
        leejam.persons corp
        ON corp.center = ca.center
        AND corp.id = ca.id
WHERE
        ca.state IN (1,4) -- AGreement must be active
        AND
        ca.center||'p'||ca.id||'rpt'||ca.subid IN (:AgreementID)
        AND
        ca.center IN (:Scope)