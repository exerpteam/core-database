-- The extract is extracted from Exerp on 2026-02-08
-- ES-20603

SELECT
    p.CENTER||'p'||p.ID  AS MEMBER,
    CASE p.BLACKLISTED
        WHEN 0 THEN 'NONE'
        WHEN 1 THEN 'BLACKLISTED'
        WHEN 2 THEN 'SUSPENDED'
        WHEN 3 THEN 'BLOCKED'
    END AS MEMBER_STATUS,
    p.EXTERNAL_ID
FROM
    PERSONS p
WHERE
    p.BLACKLISTED > 0
    AND p.CENTER in (:Scope)
