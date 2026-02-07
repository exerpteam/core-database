WITH
    PARAMS AS
    (
        SELECT
            ID   AS CENTERID,
            NAME AS CENTERNAME,
            CAST(datetolongc(TO_CHAR(to_date(:from_date, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS') , c.id) AS BIGINT) FROM_DATE,
            CAST(datetolongc(TO_CHAR(to_date(:to_date, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            CENTERS c
    )
SELECT
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS reservationdate,
    b.name                                                        AS booking,
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS reservation_date, -- to_char
    -- ( ,'FMMonth dd, yyyy' )
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS stopdate,
    b.center                                                      AS center,
    params.centername                                             AS club_of_camp,
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS starttime,
    b.name                                                        AS program_name,
    p.firstname||' '||p.lastname                                  AS fullname,
    p.sex,
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS age,
    cp.external_id                                               AS personexternalid,
    CASE
        WHEN swimtest.name IS NOT NULL
        THEN 'SW'
        ELSE ''
    END AS sw,
    CASE
        WHEN rockwall.name IS NOT NULL
        THEN 'RW'
        ELSE ''
    END AS rw,
    CASE
        WHEN qa.status = 'COMPLETED'
        THEN 'PA'
        ELSE ''
    END AS pa,
    a.external_id,
    CASE
        WHEN pa.on_waiting_list
        THEN 'Y'
        ELSE 'N'
    END AS wl,
    p.lastname ,
    p.firstname
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
AND a.activity_type = 2 --CLASS
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
LEFT JOIN
    (
        SELECT
            rank() over (partition BY p.current_person_center, p.current_person_id ORDER BY
            swimtest.creation_time DESC) AS rnk,
            p.current_person_center,
            p.current_person_id,
            swimtest.creation_time,
            swimtest.expiration_date,
            swimtest.name
        FROM
            journalentries swimtest
        JOIN
            persons p
        ON
            swimtest.person_center = p.center
        AND swimtest.person_id = p.id
        WHERE
            swimtest.name = 'Swim Test'
        AND swimtest.state = 'ACTIVE' ) swimtest
ON
    swimtest.current_person_center = p.current_person_center
AND swimtest.current_person_id = p.current_person_id
AND swimtest.rnk = 1
LEFT JOIN
    (
        SELECT
            rank() over (partition BY p.current_person_center, p.current_person_id ORDER BY
            rockwall.creation_time DESC) AS rnk,
            p.current_person_center,
            p.current_person_id,
            rockwall.creation_time,
            rockwall.expiration_date,
            rockwall.name
        FROM
            journalentries rockwall
        JOIN
            persons p
        ON
            rockwall.person_center = p.center
        AND rockwall.person_id = p.id
        WHERE
            rockwall.name = 'Rockwall Waiver'
        AND rockwall.state = 'ACTIVE' ) rockwall
ON
    rockwall.current_person_center = p.current_person_center
AND rockwall.current_person_id = p.current_person_id
AND rockwall.rnk = 1
LEFT JOIN
    (
        SELECT
            rank() over (partition BY p.current_person_center, p.current_person_id ORDER BY
            qat.log_time DESC) AS rnk,
            p.current_person_center,
            p.current_person_id,
            qat.status,
            qat.expiration_date,
            qat.log_time,
            qat.questionnaire_campaign_id
        FROM
            questionnaire_campaigns qc_pa_agreement
        JOIN
            questionnaire_answer qat
        ON
            qat.questionnaire_campaign_id=qc_pa_agreement.id
        JOIN
            persons p
        ON
            qat.center = p.center
        AND qat.id= p.id
        WHERE
            qc_pa_agreement.name LIKE '%Kids Participation Agreement%'
        AND qat.status = 'COMPLETED' ) qa
ON
    qa.rnk = 1
AND qa.current_person_center = p.current_person_center
AND qa.current_person_id = p.current_person_id
JOIN
    persons cp
ON
    cp.center = p.current_person_center
AND cp.id = p.current_person_id
WHERE
    b.starttime BETWEEN params.FROM_DATE AND params.TO_DATE
AND b.center IN (:center)
AND a.external_id IN (:external_id)
ORDER BY
   b.name, b.starttime, wl, p.lastname ,p.firstname