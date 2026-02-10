-- The extract is extracted from Exerp on 2026-02-08
--  
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
SELECT DISTINCT
        t."Member ID",
        t."Member External ID",
        t."Member Name",
        t."Club Name",
        t."Person Status",
        t."Company",
        t."Company Agreement",
        t."Attended Club",
        t."Attend Date",
        t."Attend Time",
        t."Swipe Status",
        t."Subscription Name"
FROM
        (        
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
            pr.name AS "Subscription Name"
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
        JOIN
            subscriptions s
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
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
            com.center ||'p'|| com.id = :company
        AND scl.stateid = 1
        AND ch.checkin_time BETWEEN par.fromDateLong AND par.toDateLong
        AND s.start_date <= par.toDate
        AND (
                s.end_date IS NULL
            OR  s.end_date >= par.fromDate)
        AND ch.checkin_result in(1,2)
        ORDER BY
            ch.checkin_time,
            ch.checkin_center
        )t    