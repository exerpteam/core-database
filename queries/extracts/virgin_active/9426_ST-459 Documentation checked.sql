SELECT
    c.CENTER || 'p' || c.ID "Company id" ,
    c.LASTNAME "Company name",
    ca.CENTER || 'ca' || ca.ID || 'agr' || ca.SUBID "Company agreement id",
    ca.NAME "Company agreement name",
    ca.DOCUMENTATION_REQUIRED "Documentation required?",
    ca.DOCUMENTATION_INTERVAL || ' ' || DECODE(ca.DOCUMENTATION_INTERVAL_UNIT, 0, 'Week', 1, 'Days', 2, 'Month', 3, 'Year', 4, 'Hour', 5, 'Minutes', 6, 'Second') "Renewal Period",
    DECODE (rel.STATUS,0, 'Lead', 1, 'Active', 2,'Inactive', 3, 'Blocked', 'unkown') company_agreement_status,
    p.EXTERNAL_ID "Person externalid",
    p.CENTER || 'p' || p.ID pid,
    s.CENTER || 'ss' || s.ID "membership number",
    p.FULLNAME "Member full name",
    rel.EXPIREDATE "Renewal date"
FROM
    COMPANYAGREEMENTS ca
JOIN
    PERSONS c
ON
    c.CENTER = ca.CENTER
    AND c.ID = ca.ID
JOIN
    RELATIVES rel
ON
    rel.RELATIVECENTER = c.CENTER
    AND rel.RELATIVEID = c.ID
    AND rel.RTYPE = 3
	and rel.status IN ($$status$$)
JOIN
    PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.ID = rel.ID
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8)
WHERE
    ca.DOCUMENTATION_REQUIRED in ($$documentationRequired$$) 
and c.center in ($$scope$$)
and ca.blocked = 0