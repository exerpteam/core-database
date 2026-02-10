-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS "PersonID",

        p.external_id AS "External ID"
        
	,CASE
                WHEN p.status = 0 THEN 'Lead'
                WHEN p.status = 1 THEN 'Active'
                WHEN p.status = 2 THEN 'Inactive'
                WHEN p.status = 3 THEN 'Temporary Inactive'
                WHEN p.status = 4 THEN 'Transferred'
                WHEN p.status = 5 THEN 'Duplicate'
                WHEN p.status = 6 THEN 'Prospect'
                WHEN p.status = 7 THEN 'Deleted'
                WHEN p.status = 8 THEN 'Anonymized'
                WHEN p.status = 9 THEN 'Contact'
                ELSE 'Unknown'
	END AS PersonStatus
FROM persons p
JOIN account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN payment_accounts pac ON pac.center = ar.center AND pac.id = ar.id
WHERE 
        p.center = 101