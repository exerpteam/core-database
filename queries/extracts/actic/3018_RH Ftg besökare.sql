SELECT
    ca.center,
    ca.id,
    ca.center||'p'||ca.id AS CompanyId,
    ca.subid              AS agreementid,
    c.lastname            AS company,
    ca.name               AS agreement,
    p.center||'p'||p.id   AS Customer,
    p.FULLNAME            AS CustomerName,
    to_char(longToDate(cil.CHECKIN_TIME),'mm') as month,
    COUNT(cil.CHECKIN_TIME) as checkins

FROM
    COMPANYAGREEMENTS ca
JOIN PERSONS c
ON
    ca.CENTER = c.CENTER
    AND ca.ID = c.ID
JOIN RELATIVES rel
ON
    rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
JOIN PERSONS p
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
JOIN CHECKIN_LOG cil
ON
    cil.CENTER = p.CENTER
    AND cil.id = p.ID
WHERE
    -- filter company
    c.SEX = 'C'
and 
(CA.CENTER,CA.ID) IN (:companies)
    -- attends only during a period
	and cil.CHECKIN_TIME between :FromDate and :ToDate 
    AND  rel.STATUS < 3
and p.center IN ( :scope )
GROUP BY
    ca.center,
    ca.id,
    ca.center||'p'||ca.id,
    ca.subid,
    c.lastname,
    ca.name,
    p.center||'p'||p.id,
    to_char(longToDate(cil.CHECKIN_TIME),'mm'),
    p.FULLNAME
ORDER BY
    p.center||'p'||p.id,
    to_char(longToDate(cil.CHECKIN_TIME),'mm')