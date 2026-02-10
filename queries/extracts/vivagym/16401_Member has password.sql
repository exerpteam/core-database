-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    CASE
        WHEN p.password_hash IS NOT NULL
        THEN 'true'
        ELSE 'false'
    END AS has_password
FROM
    vivagym.persons p
WHERE
    p.external_id IN (:externalId)