WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$fromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS FromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$toDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS ToDate
        FROM
            centers c
    )
SELECT
    cen.NAME                      AS "Home club" ,
    bookingcen.name               AS "Booking center" ,
    person.center||'p'||person.id AS "PNumber" ,
    person.fullname               AS "Full Name" ,
    person.external_id            AS "External id" ,
    email.TXTVALUE                AS "Email" ,
    phonehome.TXTVALUE            AS "HomePhone" ,
    mobile.TXTVALUE               AS "Mobile" ,
    ag.name                       AS "Activity type" ,
    CASE USER_INTERFACE_TYPE
        WHEN 0
        THEN 'App'
        WHEN 1
        THEN 'Staff'
        WHEN 2
        THEN 'Website'
        WHEN 3
        THEN 'KIOSK'
        WHEN 4
        THEN 'SCRIPT'
        WHEN 0
        THEN 'API'
        WHEN 0
        THEN 'MOBILE API'
        ELSE 'UNKNOWN'
    END                                                                       AS "Booking interface" ,
    TO_CHAR(longToDateC(bo.STARTTIME, bo.center),'YYYY-MM-DD HH24:MI')        AS "Class start" ,
    TO_CHAR(longToDateC(par.CREATION_TIME, par.center), 'YYYY-MM-DD HH24:MI') AS "Booking date" ,
    an.name                                                                   AS "activity" ,
    par.CREATION_BY_CENTER || 'p' || par.CREATION_BY_ID                       AS "Person Who Booked Class"
FROM
    persons person
JOIN
    params
ON
    params.id = person.id
JOIN
    participations par
ON
    person.center = par.participant_center
    AND person.id = par.participant_id
JOIN
    privilege_usages pu
ON
    par.center = pu.target_center
    AND par.id = pu.target_id
    AND PU.TARGET_SERVICE = 'Participation'
JOIN
    bookings bo
ON
    par.booking_center = bo.center
    AND par.booking_id = bo.id
JOIN
    activity an
ON
    bo.activity = an.id
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = an.activity_group_id
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    mobile.PERSONCENTER = person.CENTER
    AND mobile.PERSONID = person.ID
    AND mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS phonehome
ON
    phonehome.PERSONCENTER = person.CENTER
    AND phonehome.PERSONID = person.ID
    AND phonehome.NAME = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = person.CENTER
    AND email.PERSONID = person.ID
    AND email.NAME = '_eClub_Email'
JOIN
    CENTERS cen
ON
    cen.ID = person.CENTER
JOIN
    CENTERS bookingcen
ON
    bookingcen.ID = bo.CENTER
WHERE
    PU.privilege_type = 'BOOKING'
    AND par.cancelation_reason = 'NO_SHOW'
    AND par.booking_center IN ($$Scope$$)
    AND par.START_TIME >= params.FromDate
    AND par.START_TIME <= params.ToDate
    AND ag.name IN ($$activity_group_name$$)
ORDER BY
    person.center,
    person.id,
    par.START_TIME