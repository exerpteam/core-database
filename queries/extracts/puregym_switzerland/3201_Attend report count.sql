-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
            dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),
            c.id)-1 AS toDate,
            c.id
        FROM
            centers c
        WHERE
            c.id IN (:Scope)
    )
    SELECT
    COUNT(*),
    *
    FROM
    (
SELECT
   -- att.person_center || 'p' || att.person_id AS personId,
    att.center,
    cc.name AS center_name,
    TO_CHAR(longtodateC(att.start_time, att.center), 'YYYY-MM-dd') AS
    checkin_date,
/*    (
        CASE c.checkin_result
            WHEN 0
            THEN 'Undefined'
            WHEN 1
            THEN 'accessGranted'
            WHEN 2
            THEN 'Staff Manual CheckedIn'
            WHEN 3
            THEN 'accessDenied'
            ELSE 'Undefined'
        END) AS CheckIn_Result, */
    (
        CASE
            WHEN att.origin=0
            THEN 'Unknown'
            WHEN att.origin=1
            THEN 'Membercard'
            WHEN att.origin=2
            THEN 'Offline'
            WHEN att.origin=3
            THEN 'External'
            WHEN att.origin=4
            THEN 'QR'
            WHEN att.origin=5
            THEN 'Legacy'
            ELSE 'Undefined'
        END) AS origin,
        br.name AS resource_name,
br.external_id AS resource_id
FROM
    attends att
JOIN
    params par
ON
    par.id = att.center
JOIN
    centers cc
ON
    cc.id = att.center
JOIN
booking_resources br
ON
br.center = att.booking_resource_center
AND br.id = att.booking_resource_id
WHERE
    att.start_time BETWEEN par.fromDate AND par.toDate
    ) t1
    GROUP BY
    t1.center,
    t1.center_name,
    t1.checkin_date,
    t1.origin,
    t1.resource_name,
t1.resource_id
ORDER BY
t1.center,
t1.checkin_date,
t1.resource_name