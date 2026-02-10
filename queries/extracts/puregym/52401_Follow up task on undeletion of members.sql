-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6371
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            ADD_MONTHS(TRUNC(SYSDATE), - $$Inactivity_Period$$)                                                                                 AS deletePeriod,
            (datetolongTZ(TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE), -$$Inactivity_Period$$), 'YYYY-MM-dd HH24:MI'), 'Europe/London') + 86400 * 1000)-1 AS deletePeriodLong
        FROM
            dual
    )
SELECT
    p.center || 'p' || p.id                                                                                                                                                         AS PersonId,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "Person Status",
    TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD')                                                                                                                                  AS "Last Active Startdate",
    TO_CHAR(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')                                                                                                                                    AS "Last Active Enddate",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                                  AS "Last Modified Date",
    prod.name                                                                                                                                                                       AS "Last Membership Name"
FROM
    persons p
CROSS JOIN
    params
LEFT JOIN
    (
        SELECT
            s1.owner_center,
            s1.owner_id,
            MAX(s1.start_date) AS start_date
        FROM
            subscriptions s1
        GROUP BY
            s1.owner_center,
            s1.owner_id )latest_sub
ON
    latest_sub.owner_center = p.center
    AND latest_sub.owner_id = p.id
LEFT JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.start_date = latest_sub.start_date
LEFT JOIN
    products prod
ON
    prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
WHERE
    p.center IN ($$Scope$$)
    AND p.status IN ($$Member_Status$$)
    AND p.sex != 'C'
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            checkins c
        WHERE
            c.person_center = p.center
            AND c.person_id = p.id
            AND c.checkin_time > params.deletePeriodLong)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            attends a
        WHERE
            a.person_center = p.center
            AND a.person_id = p.id
            AND a.state <> 'CANCELLED'
            AND a.start_time > params.deletePeriodLong)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            participations part
        WHERE
            part.center = p.center
            AND part.id = p.id
            AND part.state <> 'CANCELLED'
            AND part.start_time > params.deletePeriodLong)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            state_change_log scl
        WHERE
            scl.center = p.center
            AND scl.id = p.id
            AND scl.entry_type = 1
            AND scl.book_start_time > params.deletePeriodLong)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            account_receivables ar
        WHERE
            ar.customercenter = p.center
            AND ar.customerid = p.id
            AND ar.balance <> 0
            AND ar.last_entry_time > params.deletePeriodLong)
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            relatives compCont
        WHERE
            compCont.relativecenter = p.center
            AND compCont.relativeid = p.id
            AND compCont.rtype = 7
            AND compCont.status <> 3)
ORDER BY 3