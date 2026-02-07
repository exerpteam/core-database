-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-2715
WITH params AS Materialized
(
   SELECT CAST(DATE_TRUNC('month', add_months(current_date,1))  + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE) AS end_of_next_month
)
SELECT
    s.CENTER AS "Center ID",
    c.SHORTNAME AS "Center Name",
    CASE s.STATE  WHEN 2 THEN  'ACTIVE'  WHEN 3 THEN  'ENDED'  WHEN 4 THEN  'FROZEN' ELSE 'OTHER' END    AS State,
    COUNT(*) AS "Sum ending this & next m."
FROM
    params,
    SUBSCRIPTIONS s

JOIN CENTERS c
ON
    s.CENTER = c.ID
JOIN PERSONS p
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
JOIN PRODUCT_GROUP PG
ON
    (
        PG.ID = PR.PRIMARY_PRODUCT_GROUP_ID
    )
WHERE
	s.CENTER in (:Scope)
    AND s.END_DATE >= current_timestamp
    AND s.END_DATE <= params.end_of_next_month 
    AND p.PERSONTYPE <> 2
    AND PR.PRIMARY_PRODUCT_GROUP_ID IN (6,7)
    AND s.SUB_STATE NOT IN (3,5,6)
GROUP BY
    s.CENTER,
    c.SHORTNAME,
    s.STATE
ORDER BY s.CENTER

