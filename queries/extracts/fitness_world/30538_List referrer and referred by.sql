-- This is the version from 2026-02-05
-- ST-609
SELECT
    p2.CENTER                 club_id,
    p.center || 'p' || p.ID   Referrer_id,
    p.FULLNAME                Referrer_name,
    p2.CENTER || 'p' || p2.ID Referred_by_id,
    p2.FULLNAME               Referred_by_name
FROM
    RELATIVES rel
JOIN
    PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.ID = rel.ID
JOIN
    PERSONS p2
ON
    p2.CENTER = rel.RELATIVECENTER
    AND p2.ID = rel.RELATIVEID
JOIN
    STATE_CHANGE_LOG scl
ON
    scl.CENTER = rel.CENTER
    AND scl.ID = rel.ID
    AND scl.SUBID = rel.SUBID
    AND scl.ENTRY_TYPE = 4
WHERE
    rel.RTYPE = 13
    AND scl.STATEID = 1
    AND scl.ENTRY_START_TIME >= $$fromDate$$
    AND (
        scl.ENTRY_END_TIME IS NULL
        OR scl.ENTRY_END_TIME > $$toDate$$)
    AND scl.CENTER IN ($$scope$$)