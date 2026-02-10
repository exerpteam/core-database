-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER || 'p' || p.id pid,
    p.FULLNAME,
    ar.BALANCE,
    CASE p.persontype
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS "PersonType"
FROM
    STATE_CHANGE_LOG scl
JOIN
    persons p
ON
    p.CENTER = scl.CENTER
    AND p.ID = scl.ID
    AND scl.ENTRY_START_TIME < dateToLongC(TO_CHAR(CAST(now() AS DATE)-4,'YYYY-MM-dd HH24:MI'), p.CENTER)
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.BALANCE != 0
WHERE
    scl.ENTRY_TYPE = 1
    AND scl.ENTRY_END_TIME IS NULL
    AND scl.STATEID = 1
    AND p.CENTER IN ($$Scope$$)
    AND p.persontype NOT IN (2,4) 