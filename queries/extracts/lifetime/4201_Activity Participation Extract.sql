-- The extract is extracted from Exerp on 2026-02-08
-- Enter the external id of the activity, and it will return participations for the specified date range.
with params as (
SELECT
             c.name as club_of_camp,
            c.id AS CENTER_ID,
            datetolongc(TO_CHAR(to_date(:from, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS') , c.id) AS FROM_DATE,
            datetolongc(TO_CHAR(to_date(:to, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN (151)
    )
SELECT distinct 
    to_char(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') as reservationdate,
    b.name as booking,
    to_char(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS reservation_date, -- to_char( ,'FMMonth dd, yyyy' )                   
    to_char(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS stopdate,
    b.center                         AS center,
    params.club_of_camp                            AS club_of_camp,   
    to_char(longtodatec(b.starttime,b.center),'FMMonth dd, yyyy') AS starttime,
    b.name                           AS program_name,
    p.fullname,
    p.sex,
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS age,
    p.external_id                                                AS personexternalid,
    case when swimtest.name is not null then 'SW'
    else ''
    end as sw,
    case when rockwall.name is not null then 'RW'
    else ''
    end as rw,
    case when 
    qa.status = 'COMPLETED' then 'PA'
    else ''
    end as pa,
    a.external_id
FROM
    lifetime.bookings b 
JOIN
    params  on b.center = params.CENTER_ID

    join lifetime.activity a on b.activity = a.id
    and a.activity_type = 2 --CLASS
JOIN
    lifetime.participations pa 
ON
    pa.booking_center = b.center
    and pa.booking_id = b.id
    --and pa.state != 'CANCELLED'
JOIN
    persons p
ON
    p.center = pa.participant_center
AND p.id = pa.participant_id
left join lifetime.journalentries swimtest on swimtest.person_center = p.center
and swimtest.person_id = p.id
and swimtest.name = 'Swim Test'
LEFT JOIN
            lifetime.journalentries rockwall
        ON
            p.center = rockwall.person_center
        AND p.id =rockwall.person_id
        AND rockwall.name ='Rockwall Waiver'
        left JOIN
            questionnaire_campaigns qc_pa_agreement
        ON
            qc_pa_agreement.name ='LT Kids Participation Agreement'
        LEFT JOIN
            questionnaire_answer qa
        ON
            p.center = qa.center
        AND p.id=qa.id
        AND qa.questionnaire_campaign_id=qc_pa_agreement.id
where 
b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE
and a.external_id in (:external_id) 