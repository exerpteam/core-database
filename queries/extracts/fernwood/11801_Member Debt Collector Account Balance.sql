SELECT
        c.name AS "Club Name"
		,p.center || 'p' || p.id AS "Person ID"
		,p.external_id AS "External ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,ar.balance AS "Debt Collector Account Balance"   
FROM 
        fernwood.persons p
JOIN
        fernwood.centers c
		ON c.id = p.center   
JOIN 
        fernwood.account_receivables ar 
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid 
        AND ar.ar_type = 5 
        AND ar.balance != 0                                                                                                              
WHERE 
        p.center in (:Scope)