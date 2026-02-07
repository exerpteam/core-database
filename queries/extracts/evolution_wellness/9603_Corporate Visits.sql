WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(:fromDate, 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromDateLong,
            CAST(datetolongC(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD')+interval '1 day', 'YYYY-MM-DD')
            , c.id) AS BIGINT)               AS toDateLong,
            TO_DATE(:fromDate, 'YYYY-MM-DD') AS fromDate,
            TO_DATE(:todate, 'YYYY-MM-DD')   AS toDate,
            c.ID                             AS CenterID,
            c.name                           AS centerName
        FROM
            centers c
    )
SELECT
    p.center ||'p'|| p.id AS "Member ID",
    p.external_id         AS "Member External ID",
    p.fullname            AS "Member Name",
    par.centerName        AS "Club Name",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END                                                                     AS "Person Status",
    com.fullname                                                            AS "Company",
    ca.name                                                                 AS "Company Agreement",
    cen.name                                                                AS "Attended Club",
    TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'DD-MM-YYYY')  AS "Attend Date",
    TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'HH:MI:SS AM') AS "Attend Time",
    CASE
        WHEN ch.checkin_failed_reason IS NULL
        THEN 'OK'
        ELSE ch.checkin_failed_reason
    END     AS "Swipe Status",
    t.name AS "Subscription Name"
FROM
    persons p
JOIN
    params par
ON
    par.centerId = p.center
JOIN
    evolutionwellness.relatives re
ON
    re.center = p.center
AND re.id = p.id
AND re.rtype = 3
JOIN
    evolutionwellness.state_change_log scl
ON
    scl.center = re.center
AND scl.id = re.id
AND scl.subid = re.subid
JOIN
companyagreements ca
ON
ca.center = re.relativecenter
AND ca.id = re.relativeid
AND ca.subid = re.relativesubid
JOIN
    checkins ch
ON
    ch.person_center = re.center
AND ch.person_id = re.id
AND ch.checkin_time >= scl.entry_start_time
AND (
        ch.checkin_time <= scl.entry_end_time
    OR  scl.entry_end_time IS NULL)
JOIN
    centers cen
ON
    cen.id = ch.checkin_center
JOIN
    persons com
ON
    re.relativecenter = com.center
AND re.relativeid = com.id
LEFT JOIN
(SELECT
s.owner_center,
s.owner_id,
pr.name
FROM
    subscriptions s
JOIN
	params
ON
	params.CenterID = s.center
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
WHERE
s.start_date <= params.toDate
AND (
        s.end_date IS NULL
    OR  s.end_date >= params.fromDate) ) t
ON
t.owner_center = p.center
AND t.owner_id = p.id
WHERE
    com.center ||'p'|| com.id = :company
AND scl.stateid = 1
AND ch.checkin_time BETWEEN par.fromDateLong AND par.toDateLong
ORDER BY
    ch.checkin_time,
    ch.checkin_center	