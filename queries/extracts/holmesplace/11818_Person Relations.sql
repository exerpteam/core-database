-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-726
SELECT
    r.CENTER || 'p' || r.ID                 AS "Member Id",
    p.FULLNAME                              AS "Full Name",
    r.RELATIVECENTER || 'p' || r.RELATIVEID AS "Other Member Id",
    CASE r.RTYPE
        WHEN 1
        THEN 'My friend'
        WHEN 4
        THEN 'My family'
        WHEN 9
        THEN 'My counsellor'
        WHEN 12
        THEN 'Paid for by me'
        WHEN 13
        THEN 'My referrer'
        ELSE 'UNKNOWN'
    END AS "Type of Relation",
    CASE r.STATUS
        WHEN 0
        THEN 'Lead'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Inactive'
        WHEN 3
        THEN 'Blocked'
        ELSE 'unkown'
    END                                                                                                                      AS "State of Relation",
    TO_CHAR(longtodate(MIN(scl.ENTRY_START_TIME) OVER (PARTITION BY scl.CENTER, scl.ID, scl.SUBID)),'YYYY-MM-DD HH24:MI:SS') AS "Date Of Relation"
FROM
    RELATIVES r
JOIN
    PERSONS p
ON
    r.CENTER = p.CENTER
    AND r.ID = p.ID
LEFT JOIN
    STATE_CHANGE_LOG scl
ON
    ENTRY_TYPE=4
    AND scl.CENTER = r.CENTER
    AND scl.ID = r.ID
    AND scl.SUBID = r.SUBID
WHERE
    r.RTYPE NOT IN (2,3,5,6,7,8,10,11)
    AND p.STATUS IN (0,1,2,3,6,9)
    AND p.SEX != 'C'
    AND p.CENTER IN ($$scope$$)
    AND scl.ENTRY_START_TIME BETWEEN $$startDate$$ AND $$endDate$$
UNION
SELECT DISTINCT
    r.RELATIVECENTER || 'p' || r.RELATIVEID AS "Member Id",
    p.FULLNAME                              AS "Full Name",
    r.CENTER || 'p' || r.ID                 AS "Other Member Id",
    CASE r.RTYPE
        WHEN 1
        THEN 'Friends of me'
        WHEN 4
        THEN 'Family to me'
        WHEN 9
        THEN 'Counselled by me'
        WHEN 12
        THEN 'My Payer'
        WHEN 13
        THEN 'Referred by me'
        ELSE 'UNKNOWN'
    END AS "Type of Relation",
    CASE r.STATUS
        WHEN 0
        THEN 'Lead'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Inactive'
        WHEN 3
        THEN 'Blocked'
        ELSE 'unkown'
    END                                                                                                                      AS "State of Relation",
    TO_CHAR(longtodate(MIN(scl.ENTRY_START_TIME) OVER (PARTITION BY scl.CENTER, scl.ID, scl.SUBID)),'YYYY-MM-DD HH24:MI:SS') AS "Date Of Relation"
FROM
    RELATIVES r
JOIN
    PERSONS p
ON
    r.RELATIVECENTER = p.CENTER
    AND r.RELATIVEID = p.ID
LEFT JOIN
    STATE_CHANGE_LOG scl
ON
    ENTRY_TYPE=4
    AND scl.CENTER = r.CENTER
    AND scl.ID = r.ID
    AND scl.SUBID = r.SUBID
    AND scl.ENTRY_END_TIME IS NULL
WHERE
    r.RTYPE NOT IN (2,3,5,6,7,8,10,11)
    AND p.STATUS IN (0,1,2,3,6,9)
    AND p.SEX != 'C'
    AND p.CENTER IN ($$scope$$)
    AND scl.ENTRY_START_TIME BETWEEN $$startDate$$ AND $$endDate$$