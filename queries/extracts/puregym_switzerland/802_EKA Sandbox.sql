-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) as fromDate,
                dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 as toDate,
                c.id
        FROM centers c
		WHERE c.id IN (:Scope)
)
SELECT
        a.person_center || 'p' || a.person_id AS personId,
a.booking_resource_center,
c.name,
br.name,
        longtodatec(a.start_time, a.booking_resource_center) AS checkin_datetime,
a.attend_using_card
FROM attends a
JOIN params par ON a.booking_resource_center = par.id
JOIN centers c ON a.booking_resource_center = c.id
JOIN booking_resources br ON br.id = a.booking_resource_id
WHERE
        a.start_time between par.fromDate AND par.toDate
ORDER BY 2