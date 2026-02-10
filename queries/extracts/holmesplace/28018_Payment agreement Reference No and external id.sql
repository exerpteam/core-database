-- The extract is extracted from Exerp on 2026-02-08
-- Payment agreement Reference numbers with Person External Id and Person Id

SELECT 
         p.external_id
        ,p.center||'p'||p.ID AS "Member id"
        ,p.FULLNAME AS "Member full name"
        ,pag.Ref AS "Ref."
        ,ch.NAME  ,
		CASE p.status
			WHEN 0 THEN 'LEAD'
			WHEN 1 THEN 'ACTIVE'
			WHEN 2 THEN 'INACTIVE'
			WHEN 3 THEN 'TEMPORARYINACTIVE'
			WHEN 4 THEN 'TRANSFERRED'
			WHEN 5 THEN 'DUPLICATE'
			WHEN 6 THEN 'PROSPECT'
			WHEN 7 THEN 'DELETED'
			WHEN 8 THEN 'ANONYMIZED'
			WHEN 9 THEN 'CONTACT'
			ELSE 'Undefined'
		END
FROM persons p
JOIN account_receivables ar 
                ON ar.customercenter = p.center 
                AND ar.customerid = p.id 
                AND ar.ar_type = 4
JOIN payment_accounts pa 
                ON pa.center = ar.center 
                AND pa.id = ar.id 
JOIN payment_agreements pag 
                ON pag.center = pa.active_agr_center
                AND pag.ID = pa.active_agr_id 
                AND pag.subid = pa.active_agr_subid 
JOIN CENTERS c 
                ON c.ID = p.Center
JOIN CLEARINGHOUSES ch 
                ON ch.ID = pag.clearinghouse
WHERE 
                p.Status Not in (4,5,7,8)
                AND pag.State in (1,2,4,13)
                AND p.SEX != 'C'
                AND p.Center in (:Scope)