-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-5158
SELECT
    p.CENTER                     AS "HOME_CENTER_PERSON",
    p.CENTER || 'p' || p.ID                         AS "PERSON_ID",
    p.FULLNAME                   AS "FULL_NAME",
    pr.NAME                      AS "SUBSCRIPTION_NAME",
    s.CENTER                     AS "SUBSCRIPTION_HOME CENTER",   
    s.START_DATE                 AS "START_DATE",
    s.END_DATE                   AS "STOP_DATE",
    S.BINDING_END_DATE           AS "SUBSCRIPTION_BINDING_DATE"
FROM
    persons p
JOIN centers cr
    ON p.CENTER=cr.ID AND cr.COUNTRY='IT'
JOIN
    subscriptions s
ON
    p.CENTER = s.OWNER_CENTER
AND p.ID = s.OWNER_ID
JOIN
    products pr
ON
    pr.CENTER=s.SUBSCRIPTIONTYPE_CENTER
AND pr.ID=s.SUBSCRIPTIONTYPE_ID
WHERE
    p.CENTER !=s.CENTER
AND p.CENTER IN (:Scope)