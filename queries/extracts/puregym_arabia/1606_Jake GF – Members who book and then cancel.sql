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
    person.external_id            AS "External id" ,
    ag.name                       AS "Activity type",
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
    END                                                                                                                                                         AS "Booking interface" ,
    TO_CHAR(longToDateC(bo.STARTTIME, bo.center),'YYYY-MM-DD HH24:MI')                                                                                          AS "Class start" ,
    TO_CHAR(longtodateC(par.CREATION_TIME, par.center), 'YYYY-MM-DD HH24:MI')                                                                                   AS "Booking date" ,
    TO_CHAR(longtodateC(par.CANCELATION_TIME, par.center), 'YYYY-MM-DD HH24:MI')                                                                                AS "Cancel date" ,
    an.name                                                                                                                                                     AS "activity" ,
    CAST (EXTRACT(YEAR FROM AGE(now(), CAST(person.birthdate AS TIMESTAMP))) * 12 + EXTRACT(MONTH FROM AGE(now(), CAST(person.birthdate AS TIMESTAMP))) AS INT) AS "age",
    CASE
        WHEN prod.NAME IS NOT NULL
        THEN prod.NAME
        ELSE prodn.NAME
    END AS "SUB_COMMENT" ,
    CASE person.SEX
        WHEN 'M'
        THEN 'Male'
        WHEN 'F'
        THEN 'Female'
        WHEN 'C'
        THEN 'Company'
        ELSE 'Unknown'
    END AS "Gender",
    CASE
        WHEN ss.START_DATE IS NOT NULL
        THEN ss.START_DATE
        ELSE ssn.START_DATE
    END                                                                                        AS "LAST_SUB_START_DATE" ,
    CAST(DATE_PART('day', now() - CAST(person.LAST_ACTIVE_START_DATE AS TIMESTAMP)) AS INT) +1 AS "UNBROKEN_MEMBERSHIP_DAYS" ,
    par.CREATION_BY_CENTER || 'p' || par.CREATION_BY_ID                                        AS "Booking Created by ID" ,
    par.CANCELATION_BY_CENTER || 'p' || par.CANCELATION_BY_ID                                  AS "Booking Cancelled by ID"
FROM
    persons person
JOIN
    params
ON
    params.id = person.center
LEFT JOIN
    (
        SELECT
            MAX(ID) AS SubID,
            OWNER_CENTER,
            OWNER_ID,
            CENTER
        FROM
            SUBSCRIPTIONS
        WHERE
            STATE IN (2,4,8)
        GROUP BY
            OWNER_CENTER,
            OWNER_ID,
            CENTER) s1
ON
    s1.OWNER_CENTER = person.CENTER
    AND s1.OWNER_ID = person.ID
LEFT JOIN
    SUBSCRIPTIONS ss
ON
    s1.SubID = ss.ID
    AND s1.CENTER = ss.CENTER
    AND s1.OWNER_CENTER = ss.OWNER_CENTER
    AND s1.OWNER_ID = ss.OWNER_ID
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = ss.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = ss.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    (
        SELECT
            MAX(ID) AS SubID,
            OWNER_CENTER,
            OWNER_ID,
            CENTER
        FROM
            SUBSCRIPTIONS
        WHERE
            STATE NOT IN (2,4,8)
        GROUP BY
            OWNER_CENTER,
            OWNER_ID,
            CENTER) s2
ON
    s2.OWNER_CENTER = person.CENTER
    AND s2.OWNER_ID = person.ID
LEFT JOIN
    SUBSCRIPTIONS ssn
ON
    s2.SubID = ssn.ID
    AND s2.CENTER = ssn.CENTER
    AND s2.OWNER_CENTER = ssn.OWNER_CENTER
    AND s2.OWNER_ID = ssn.OWNER_ID
LEFT JOIN
    PRODUCTS prodn
ON
    prodn.CENTER = ssn.SUBSCRIPTIONTYPE_CENTER
    AND prodn.id = ssn.SUBSCRIPTIONTYPE_ID
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
    AND par.state = 'CANCELLED'
    AND bo.STARTTIME >= par.CANCELATION_TIME
    AND par.booking_center IN ($$Scope$$)
    AND par.START_TIME >= params.FromDate
    AND par.START_TIME <= params.ToDate