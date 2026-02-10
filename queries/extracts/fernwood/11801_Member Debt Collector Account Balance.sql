-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        c.name AS "Club Name"
		,p.center || 'p' || p.id AS "Person ID"
		,p.external_id AS "External ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,ar.balance AS "Debt Collector Account Balance"   
FROM 
        persons p
JOIN
        centers c
		ON c.id = p.center   
JOIN 
        account_receivables ar 
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid 
        AND ar.ar_type = 5 
        AND ar.balance != 0                                                                                                              
WHERE 
        p.center in (:Scope)