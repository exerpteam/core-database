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
SELECT DISTINCT
    att.person_center || 'p' || att.person_id AS personId,
    att.center,
p.external_id,
    cc.name,
    TO_CHAR(longtodateC(att.start_time, att.center), 'YYYY-MM-dd HH24:MI') AS
    checkin_datetime,
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
        br.name
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
JOIN
persons p
ON p.id = att.person_id AND p.center = att.person_center
WHERE
    att.start_time BETWEEN par.fromDate AND par.toDate
ORDER BY
    att.center,
    checkin_datetime