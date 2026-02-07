WITH
    params AS
    (
        SELECT
            c.name AS center,
            c.id   AS CENTER_ID,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateFrom$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS BIGINT) AS from_date,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateTo$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), c.time_zone) AS BIGINT) + (24*60*60*1000) AS to_date
        FROM
            centers c
        WHERE
            c.id IN ($$Scope$$)
    )
SELECT
    par.CENTER || 'pa' || par.ID         AS participation_id,
    b.CENTER || 'book' || b.ID         AS booking_id,
    b.name                             AS class_name,    
    p1.center||'p'||p1.id                AS person_id,
    p1.fullname                        AS client_name,
    pe_phone.txtvalue                   AS phone_number,
    to_char(longtodatec(b.starttime, b.center),'YYYY-MM-DD') AS start_date,    
    to_char(longtodatec(b.starttime, b.center),'HH24:MI:SS') AS start_time,
    to_char(longtodatec(b.stoptime, b.center),'YYYY-MM-DD') AS end_date,    
    to_char(longtodatec(b.stoptime, b.center),'HH24:MI:SS') AS end_time,
    par.state,
    b.class_capacity,
    su.person_center||'p'||su.person_id AS instructor,
    ps.fullname                         AS instructor_name,
    su.salary                           AS salary
FROM
    bookings b
JOIN
    params
ON
    params.center_id = b.center
JOIN
    participations par
ON
    par.booking_center = b.center
AND par.booking_id = b.id
JOIN
    persons p1
ON
    par.participant_center = p1.center
    AND par.participant_id = p1.id
JOIN
    staff_usage su
ON
    b.center = su.booking_center
AND b.id = su.booking_id
AND su.state <> 'CANCELLED'
JOIN 
    activity a
ON 
    b.activity = a.id
LEFT JOIN
   person_ext_attrs pe_phone
ON
   p1.center = pe_phone.personcenter
   AND p1.id = pe_phone.personid             
   AND pe_phone.name = '_eClub_PhoneSMS'
LEFT JOIN
   persons ps
ON
   su.person_center = ps.center
   AND su.person_id = ps.id     
WHERE
    b.starttime >= params.from_date
AND b.starttime < params.to_date
AND a.activity_type = 2 -- CLASS_BOOKING only