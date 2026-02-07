-- This is the version from 2026-02-05
--  
SELECT DISTINCT 
    p.center || 'p' || p.ID AS "Medlems ID",
    c.name AS "Stamcenter",
	p.persontype,
	pr.globalid,
	pr.name,
	p.STATUS,
    p.FULLNAME AS "Medlems navn",
    CASE 
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'TemporaryInactive'
        WHEN p.status = 4 THEN 'Transferred'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Undefined'
    END AS "Person status"
FROM persons p
LEFT JOIN account_receivables ar 
    ON ar.customercenter = p.center 
    AND ar.customerid = p.id 
	AND ar.ar_type = 4
LEFT JOIN payment_accounts pa 
    ON pa.center = ar.center 
    AND pa.id = ar.id 
LEFT JOIN payment_agreements pag 
    ON pag.center = pa.active_agr_center
    AND pag.ID = pa.active_agr_id 
    AND pag.subid = pa.active_agr_subid 
JOIN CENTERS c 
    ON c.ID = p.Center
LEFT JOIN subscriptions s 
    ON P.CENTER = S.OWNER_CENTER  
    AND P.ID = S.OWNER_ID  
LEFT JOIN PRODUCTS PR 
    ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER 
    AND PR.ID = S.SUBSCRIPTIONTYPE_ID
WHERE 
    p.Center IN (:Scope)
    AND pag.id IS NULL  -- Ensure no payment account exists
    AND pa.id IS NULL 
	AND p.status IN (1,3)
	and pr.globalid not like 'CASH%'
	and pr.globalid not like 'PREPAID%'
	and pr.globalid not like 'VOUCHER%'
	and pr.globalid not like 'STAFF%'
	and pr.globalid not like 'SPONSOR%'
	and S.STATE IN (2,7)
    AND p.persontype IN (0,1)
    AND NOT EXISTS (
        SELECT 1 
        FROM FW.RELATIVES r
        WHERE r.RELATIVECENTER = p.CENTER 
          AND r.RELATIVEID = p.ID 
          AND r.RTYPE = 12
          AND r.STATUS < 3
    )
