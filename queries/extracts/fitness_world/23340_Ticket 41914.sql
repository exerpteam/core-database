-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ci.ID checkin_id,
    longToDate(ci.CHECKIN_TIME) FAMILY_CHECKIN_TIME,
    p.CENTER || 'p' || p.ID family_PID,

    rel3.RELATIVECENTER || 'p' || rel3.RELATIVEID primary_PID,
	 ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID will_be_charged,

    ci.CHECKIN_CENTER
FROM
    FW.CHECKINS ci
JOIN FW.PERSONS p
ON
    p.CENTER = ci.PERSON_CENTER
    AND p.ID = ci.PERSON_ID
LEFT JOIN FW.RELATIVES rel
ON
    rel.RTYPE = 12
    AND rel.RELATIVECENTER = p.CENTER
    AND rel.RELATIVEID = p.ID
    AND rel.STATUS = 1
JOIN FW.ACCOUNT_RECEIVABLES ar
ON
    (
        rel.CENTER IS NULL
        AND ar.CUSTOMERCENTER = p.CENTER
        AND ar.CUSTOMERID = p.ID
        AND ar.AR_TYPE = 4
    )
    OR
    (
        rel.CENTER IS NOT NULL
        AND ar.CUSTOMERCENTER = rel.CENTER
        AND ar.CUSTOMERID = rel.ID
        AND ar.AR_TYPE = 4
    )
join FW.RELATIVES rel3 on rel3.CENTER = p.CENTER and rel3.id = p.id and rel3.RTYPE = 4 and rel3.STATUS = 1
join FW.STATE_CHANGE_LOG scl3 on scl3.CENTER = rel3.CENTER and scl3.ID = rel3.ID and scl3.ENTRY_TYPE = 4 and scl3.STATEID = 1 and scl3.ENTRY_START_TIME < 1402696800000
WHERE
    p.PERSONTYPE = 6
	and p.center in (:scope)
    AND ci.CHECKIN_TIME  > 1402696800000
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            FW.RELATIVES rel2
        JOIN FW.PERSONS p2
        ON
            p2.CENTER = rel2.RELATIVECENTER
            AND p2.ID = rel2.RELATIVEID
        JOIN FW.CHECKINS ci2
        ON
            ci2.PERSON_CENTER = p2.CENTER
            AND ci2.PERSON_ID = p2.ID
        WHERE
            rel2.CENTER = p.CENTER
            AND rel2.ID = p.ID
            AND rel2.STATUS = 1
            AND rel2.RTYPE = 4
            AND ci2.CHECKIN_TIME BETWEEN (ci.CHECKIN_TIME - (1000 * 60 * 5)) AND
            (
                ci.CHECKIN_TIME + (1000 * 60 * 5)
            )
    )