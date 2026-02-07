-- This is the version from 2026-02-05
--  
SELECT
    ci.ID,
    p.CENTER || 'p' || p.ID PERSONKEY,
    longToDate(ci.CHECKIN_TIME),
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

WHERE
    p.PERSONTYPE = 6
    AND ci.PERSON_CENTER = :center
    AND ci.CHECKIN_TIME between :startDate and :endDate
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