SELECT
    p.id                  AS PERSON_ID,
    p.creation_date       AS PERSON_CREATION_DATE,
    par.creation_datetime AS PARTICIPATION_CREATION_TIME,
    par.state             AS PARTICIPATION_SATE,
    b.start_datetime      AS BOOKING_START_TIME,
    a.id                  AS ACTIVITY_ID,
    a.activity_group_id   AS ACTIVITY_GROUP_ID
    --    UPPER(a.name)         AS ACTIVITY_NAME
FROM
    public.person p
JOIN
    public.participation par
ON
    p.id = par.person_id
    AND p.creation_date > '2018-01-01 08:00:00'
    AND p.creation_date < '2019-07-28 08:00:00'
    AND p.person_type NOT IN ('FAMILY',
                              'STAFF')
    AND p.country_id = 'GB'-- TODO : ADD CUSTOMER PERIOD START
    -- AND p.home_center_id IN (76,30)
    AND p.duplicate_of_person_id IS NULL
    AND p.city IS NOT NULL
    AND p.date_of_birth IS NOT NULL
    AND par.creation_datetime BETWEEN p.creation_date AND p.creation_date + 100-- TODO : TRANSFERRED MEMBERS THAT HAVE STARTED PT AFTER THEY TRANSFERRED
JOIN
    public.booking b
ON
    b.id = par.booking_id
JOIN
    public.activity a
ON
    a.id = b.activity_id 