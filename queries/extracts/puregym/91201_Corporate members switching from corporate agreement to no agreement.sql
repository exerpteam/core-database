-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD')-interval '1 day',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'),
            'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
            c.id                            AS CenterID
        FROM
            centers c
		WHERE
			c.id IN (:scope)
    )
SELECT
    p.center ||'p'|| p.id AS "Person ID",
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
    END                                                                          AS "Person status",
    p.fullname                                                                     AS "Member name",
    pea.txtvalue                                                                   AS "Email",
    p.center                                                                       AS "Club",
    sub.name                                                                 AS "Subscription name",
    TO_CHAR(longtodateC(scl.entry_start_time, p.center), 'DD-MM-YYYY HH:MI:SS AM') AS "Change time",
    scl.employee_center ||'emp'|| scl.employee_id AS "Staff"
FROM
    persons p
JOIN
    params par
ON
    par.centerid = p.center
JOIN
    relatives r
ON
    r.center = p.center
AND r.id = p.id
AND r.rtype = 3
AND r.status != 1
JOIN
    puregym.state_change_log scl
ON
    scl.center = r.center
AND scl.id = r.id
AND scl.subid = r.subid
AND scl.entry_type = 4
AND scl.stateid != 1
LEFT JOIN
    puregym.person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_Email'
LEFT JOIN
    (
        SELECT
            s.owner_center,
            s.owner_id,
            pr.name
        FROM
            subscriptions s
        JOIN
            puregym.subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id
        WHERE
            s.state IN (2,4) ) sub
ON
    sub.owner_center = p.center
AND sub.owner_id = p.id
WHERE
    p.status NOT IN (4,5,7,8)
AND scl.entry_start_time BETWEEN par.fromDate AND par.toDate
AND p.center != 100