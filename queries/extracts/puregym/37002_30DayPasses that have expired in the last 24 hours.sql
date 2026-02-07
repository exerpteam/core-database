SELECT
    c.id                    AS "Club ID",
    c.NAME                  AS "Club Name",
    p.center || 'p' || p.id AS "Person P Number",
    p.fullname              AS "Person Fullname",
    s.end_date              AS "30 Day Pass Expired Date"
FROM
    persons p
JOIN
    SUBSCRIPTIONS s
ON
    p.center = s.owner_center
    AND p.id = s.owner_id
    AND s.end_date = TRUNC(SYSDATE-$$offsetDays$$)
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    AND pr.GLOBALID = 'DAY_PASS_30_DAY'
JOIN
    PUREGYM.CENTERS c
ON
    c.id = p.center
WHERE
    p.center IN ($$Scope$$)