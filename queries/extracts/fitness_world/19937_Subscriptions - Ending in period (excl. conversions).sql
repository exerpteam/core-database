-- The extract is extracted from Exerp on 2026-02-08
-- Ticket 35489
SELECT
    s.OWNER_CENTER,
    s.OWNER_ID,
    s.CENTER,
    c.SHORTNAME,
    COUNT(*)
FROM
    FW.SUBSCRIPTIONS s

JOIN FW.CENTERS c
ON
    s.CENTER = c.ID
JOIN FW.PERSONS p
ON
    s.OWNER_CENTER = p.center
    AND s.OWNER_ID = p.ID
JOIN SUBSCRIPTIONTYPES ST
ON
    (
        S.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND S.SUBSCRIPTIONTYPE_ID = ST.ID
    )
JOIN PRODUCTS PR
ON
    (
        S.SUBSCRIPTIONTYPE_CENTER = PR.CENTER
        AND S.SUBSCRIPTIONTYPE_ID = PR.ID
    )
JOIN FW.PRODUCT_GROUP PG
ON
    (
        PG.ID = PR.PRIMARY_PRODUCT_GROUP_ID
    )
WHERE
    s.CENTER IN (:Scope)
    AND s.END_DATE >= :FromDate
    AND s.END_DATE <= :ToDate
    AND p.PERSONTYPE <> 2
    AND PR.PRIMARY_PRODUCT_GROUP_ID IN (6,7)
    AND s.SUB_STATE NOT IN (3,5,6)
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            FW.SUBSCRIPTIONS si
        WHERE
            si.OWNER_CENTER = s.OWNER_CENTER
            AND si.OWNER_ID = s.OWNER_ID
            AND si.ID != s.ID
            AND si.START_DATE > s.END_DATE
            AND si.STATE NOT IN (3)
    )
GROUP BY
    s.OWNER_CENTER,
    s.OWNER_ID,
    s.CENTER,
    c.SHORTNAME
ORDER BY
    s.CENTER