WITH
    params AS materialized
    (
        SELECT
            c.id                                                                          AS center,
	    CAST(datetolongc(TO_CHAR(to_date($$from_date$$, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) AS FROM_DATE,
	    CAST(datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS')+1,'YYYY-MM-DD HH24:MI:SS'), c.id)-1 AS BIGINT) AS TO_DATE
        FROM
            centers c
    )
SELECT 
    TO_CHAR(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy HH:MI AM') AS reservationdate,
    b.name                                                        AS booking,
    TO_CHAR(bp.startdate,'FMMonth dd, yyyy')                      AS reservation_date,
    TO_CHAR(bp.stopdate,'FMMonth dd, yyyy')                       AS stopdate,
    bp.center                                                     AS center,
    c.name                                                        AS club_of_camp,
    bp.name                                                       AS program_name,
    p.fullname,
    p.sex,
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS age,
    TO_CHAR(p.birthdate,'FMYYYY-MM-DD')                          AS birth_date,
    p.external_id                                                AS personexternalid,
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
        WHEN t.status = 'COMPLETED'
        THEN 'PA'
        ELSE ''
    END AS pa,
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
AND a.activity_type in (11, 12) --Camp program, elective
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
	select 
	  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
	  person_center,
	  person_id,
	  creation_time,
	  expiration_date,
	  name
	from 
	  journalentries
	WHERE
	  name = 'Swim Test'
	  AND state = 'ACTIVE'
	) swimtest
	ON
		swimtest.person_center = p.center
		AND swimtest.person_id = p.id
		AND swimtest.rnk = 1
LEFT JOIN		
     	(		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries
		WHERE
		 custom_type = 4 --name = 'Rockwall Waiver'
		  AND state = 'ACTIVE'
		) rockwall
		ON
			rockwall.person_center = p.center
			AND rockwall.person_id = p.id
			AND rockwall.rnk = 1
LEFT JOIN
    (
        SELECT
            rank() over (partition BY qa.center, qa.id ORDER BY qa.log_time DESC) AS rnk,
             qa.center,
            qa.id,
            qa.status
        FROM
            questionnaire_campaigns qc_pa_agreement
        LEFT JOIN
            questionnaire_answer qa
        ON
            qa.questionnaire_campaign_id=qc_pa_agreement.id
        WHERE
            qc_pa_agreement.name like '%Kids Participation Agreement%' ) t
ON
    t.rnk = 1
AND p.center = t.center
AND p.id=t.id
WHERE
--    bp.program_type_id IS NOT NULL
--AND 
b.starttime BETWEEN params.from_date AND params.to_date
AND b.center IN ($$center$$)
ORDER BY booking, reservationdate, birthdate ,lastname, firstname	
