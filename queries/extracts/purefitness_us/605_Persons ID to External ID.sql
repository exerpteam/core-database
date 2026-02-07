SELECT
    p.center||'p'||p.id,
    p.EXTERNAL_ID
FROM
    PERSONS p
WHERE
    (p.center,p.id) IN ($$MemberID$$)