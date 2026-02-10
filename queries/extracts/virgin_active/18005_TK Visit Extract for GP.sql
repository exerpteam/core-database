-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center||'p'||p.id                                              AS PERSONID,
    TO_CHAR(longToDateC(a.start_TIME,a.center),'YYYY-MM-dd HH24:MI') AS VisitDateTime,
    c.name                                                           AS VisitClubName
FROM
    persons p
JOIN
    attends a
ON
    a.person_center = p.center
    AND a.person_id = p.id
JOIN
    centers c
ON
    c.id = a.center
LEFT JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.center
    AND ccc.PERSONID = p.id
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT = 1
WHERE
    p.center IN (11, 12, 13, 29, 30, 33, 35, 36, 42, 47, 48, 51, 56, 59, 60, 68, 71, 75, 76, 400, 405, 407, 409, 421, 953, 954)
    -- no guest records
    AND p.persontype NOT IN (8)
    AND (
        -- active,temp inactive
        (
            p.status IN (1,3)
            AND s.state IN (2,4,8))
        -- prospect,contact
        OR (
            p.status IN (6,9)
            AND s.id IS NULL)
        -- Open debt collection case member
        OR (
            ccc.id IS NOT NULL
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s2.OWNER_CENTER = p.CENTER
                    AND s2.OWNER_ID = p.ID
                    AND NVL(s2.end_date,SYSDATE) > NVL(s.END_DATE,SYSDATE)))
        -- inactive member from last 6 months
        OR (
            p.status = 2
            AND EXISTS
            (
                SELECT
                    1
                FROM
                    STATE_CHANGE_LOG scl
                WHERE
                    scl.CENTER = p.CENTER
                    AND scl.ID = p.ID
                    AND scl.ENTRY_TYPE=1
                    AND scl.BOOK_END_TIME IS NULL
                    AND scl.STATEID=2
                    AND scl.ENTRY_START_TIME > exerpro.datetolong(TO_CHAR(add_months(SYSDATE,-6),'YYYY-MM-DD HH24:MI')))
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s2.OWNER_CENTER = p.CENTER
                    AND s2.OWNER_ID = p.ID
                    AND NVL(s2.end_date,SYSDATE) > NVL(s.END_DATE,SYSDATE))))