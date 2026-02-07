SELECT
    p.center as person_center,
	ca.CENTER || 'p' || ca.ID AS 	CompanyId,
	comp.LASTNAME AS company,
	ca.NAME AS 						Agreement,
	ca.STATE,
	ca.STOP_NEW_DATE,
	ca.AVAILABILITY,
    count(distinct(p.center||'p'||p.id)) as customer_count

FROM
	COMPANYAGREEMENTS ca
	
LEFT JOIN PERSONS comp
ON
	ca.CENTER = comp.CENTER
	AND ca.ID = comp.ID
	AND comp.SEX = 'C'
JOIN relatives rel
ON
    rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
JOIN persons p
    ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.status in (1) -- active


WHERE
	ca.BLOCKED = 0
	AND ca.STATE IN (1, 2, 3)  /*1 = 'active', 3 = 'old', 2 = 'stop new' */
	AND p.CENTER IN (:scope)
ORDER BY
	p.CENTER,
	ca.CENTER,
	ca.ID,
	ca.NAME