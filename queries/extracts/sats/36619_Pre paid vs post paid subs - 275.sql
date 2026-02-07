SELECT
    s.RENEWAL_POLICY_OVERRIDE,
    c.COUNTRY,
p.center,
    COUNT(p.CENTER) cnt
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
WHERE
    s.STATE IN (2,4,8)
	and p.center in ($$scope$$)
GROUP BY
    s.RENEWAL_POLICY_OVERRIDE,
    c.COUNTRY,
p.center