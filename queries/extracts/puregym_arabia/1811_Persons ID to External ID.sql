-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center||'p'||p.id,
    p.EXTERNAL_ID
FROM
    PERSONS p
WHERE
    (p.center,p.id) IN ($$MemberID$$)