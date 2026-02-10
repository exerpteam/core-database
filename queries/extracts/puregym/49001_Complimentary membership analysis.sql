-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4575
SELECT
    p.center||'p'||p.id AS "P number",
    p.FIRSTNAME   AS "First Name",
    p.LASTNAME  AS "Last Name",
    p.CO_NAME AS "C/O name",
    pr.NAME AS "Subscription",
    TO_CHAR(s.START_DATE,'YYYY-MM-YY') AS "Subscription start date",
    TO_CHAR(s.END_DATE,'YYYY-MM-YY') AS "Subscription end date"
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
JOIN
    PRODUCTS pr
ON
    s.SUBSCRIPTIONTYPE_CENTER = pr.center
    AND s.SUBSCRIPTIONTYPE_ID = pr.ID
WHERE
    s.START_DATE >= :From_Date
    AND s.START_DATE <= :To_Date
    AND s.STATE in (:Subscription_Status)
    AND pr.NAME in (:Subscription_Name)
    AND s.CENTER in (:Scope)
 