SELECT
    p.CENTER || 'p' || p.ID pid,
    p.FULLNAME,
    ca.CENTER || 'ca' || ca.ID || 'agr' || ca.SUBID agreement_id,
    ca.NAME agreement_name,
    c.LASTNAME COMPANY_NAME,
    rel.EXPIREDATE,
    DECODE (rel.STATUS,0, 'Lead', 1, 'Active', 2,'Inactive', 3, 'Blocked', 'unkown') company_agreement_status,
	ca.DOCUMENTATION_REQUIRED AGREEMENT_DOC_REQUIRED
    
FROM
    RELATIVES rel
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.ID = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
	and ca.blocked = 0
join PERSONS c on c.CENTER = ca.CENTER and c.ID = ca.ID
JOIN
    PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.ID = rel.ID
WHERE
    rel.RTYPE = 3
    AND rel.EXPIREDATE IS NOT NULL
and c.center in ($$scope$$)
