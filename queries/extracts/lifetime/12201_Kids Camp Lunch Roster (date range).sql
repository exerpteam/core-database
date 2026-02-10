-- The extract is extracted from Exerp on 2026-02-08
-- ST-16391: This extract will be used to make sure that all the kids that have purchased receive a lunch. Date range version.
WITH
    PARAMS AS
    (
        SELECT
            ID   AS CENTERID,
            NAME AS CENTERNAME,
            datetolongc(TO_CHAR(to_date(:from_date, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS') , c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date(:to_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'
            ), c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            CENTERS c
    )
SELECT DISTINCT
    p.external_id AS "Member ID", --personexternalid
       p.lastname AS "Camper's Last Name",
	p.firstname AS "Camper's First Name",
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER)  AS "Campers Age",
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS "Reservation Date"
FROM
    bookings b
JOIN
    params
ON
    params.centerid = b.center
JOIN
    lifetime.activity a
ON
    b.activity = a.id
AND a.activity_type = 12 --camp elective
JOIN
    participations pa
ON
    pa.booking_center = b.center
AND pa.booking_id = b.id
AND pa.state != 'CANCELLED'
JOIN
    persons p
ON
    p.center = pa.participant_center
AND p.id = pa.participant_id
WHERE
    b.starttime BETWEEN params.FROM_DATE AND params.TO_DATE
AND b.center IN (:center)
AND a.external_id = ('701591102691')
ORDER BY p.lastname asc