SELECT 
	p.external_id "PERSON_ID"
	,r.RELATIVECENTER
	,r.RELATIVEID
	,r.RELATIVESUBID 
	,r.STATUS
	,r.EXPIREDATE
FROM relatives r
	INNER JOIN persons p ON r.center = p.center AND r.id = p.id
WHERE 
	r.RTYPE = 3 
	AND r.CENTER BETWEEN :FromCenter AND :ToCenter
	AND p.external_id IS NOT NULL
