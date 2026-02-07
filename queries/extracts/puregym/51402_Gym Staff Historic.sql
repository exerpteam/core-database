SELECT
    c.NAME                  AS "Center",
    p.CENTER || 'p' || p.ID AS "P number",
    p.FULLNAME              AS  "Name",
    pr.NAME                  AS "Subscription name",
    s.start_date              AS "Subscription start date",
    null                     AS "Notes"
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
AND s.STATE IN (1,2,3,4,5,6,7,8)
AND p.PERSONTYPE = 2