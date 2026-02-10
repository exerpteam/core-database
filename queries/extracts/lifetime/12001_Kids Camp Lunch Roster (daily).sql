-- The extract is extracted from Exerp on 2026-02-08
-- ST-16391: This extract will be used to make sure that all the kids that have purchased receive a lunch. Daily version.
WITH
    PARAMS AS
    (
        SELECT
            ID   AS CENTERID,
            NAME AS CENTERNAME            
        FROM
            CENTERS c
    )
SELECT DISTINCT
    p.external_id AS "Member ID", --personexternalid
    p.lastname AS "Camper's Last Name",
	p.firstname AS "Camper's First Name",
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER)  AS "Campers Age"
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
    to_char(longtodatec(b.starttime,b.center),'yyyy-mm-dd') = to_char(NOW(),'yyyy-mm-dd')
AND b.center IN (:center)
AND a.external_id = ('701591102691')
order by p.lastname asc