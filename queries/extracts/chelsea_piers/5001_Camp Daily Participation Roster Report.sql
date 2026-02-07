WITH
    params AS materialized
    (
        SELECT
            c.id                                                                          AS center,
			datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) AS FROM_DATE,
			datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS')+1,'YYYY-MM-DD HH24:MI:SS'), c.id)-1 AS TO_DATE
        FROM
            centers c
    )
SELECT 
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS reservationdate,
    b.name                                                        AS booking,
    TO_CHAR(bp.startdate,'FMMonth dd, yyyy')                      AS reservation_date,
    TO_CHAR(bp.stopdate,'FMMonth dd, yyyy')                       AS stopdate,
    bp.center                                                     AS center,
    c.name                                                        AS club_of_camp,
    bp.name                                                       AS program_name,
    p.fullname,
    p.sex,
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS age,
    p.external_id                                                AS personexternalid,
    p.firstname,
	p.lastname
FROM
    Params
JOIN
    booking_programs bp
ON
    params.center = bp.center
JOIN
    centers c
ON
    c.id = bp.center
JOIN
    bookings b
ON
    b.booking_program_id = bp.id
JOIN
    activity a
ON
    b.activity = a.id
AND a.activity_type = 11 --Camp program
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
    bp.program_type_id IS NOT NULL
AND b.starttime BETWEEN params.from_date AND params.to_date
AND b.center IN ($$center$$)
ORDER BY booking, reservationdate, lastname, firstname	
