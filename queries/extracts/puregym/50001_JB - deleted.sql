SELECT
    p.CENTER || 'p' || p.ID AS "P number",
FROM
    subscriptions s
JOIN
    products pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    persons p
ON
    p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
JOIN
    centers c
ON
    p.CENTER = c.ID
WHERE
    p.CENTER IN ($$scope$$)
AND s.STATE IN (9)
