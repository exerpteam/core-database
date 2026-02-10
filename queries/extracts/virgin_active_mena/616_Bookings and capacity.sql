-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS (
    SELECT
        EXTRACT(EPOCH FROM $$startdate$$::TIMESTAMP) * 1000 AS PeriodStart,
        (EXTRACT(EPOCH FROM $$enddate$$::TIMESTAMP) * 1000 + 86400 * 1000) - 1 AS PeriodEnd
)
SELECT DISTINCT
    c.WEB_NAME                                                                  AS "Club name",
    bo.id,
    bo.NAME                                                                     AS "Class name",
    bo.STATE                                                                    AS "Class state",
    ag.name                                                                     AS "Class activity group",
    staff.FULLNAME                                                              AS "Instructor name",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Australia/Sydney'), 'DD-MM-YYYY')          AS "Class start date",
    TO_CHAR(longtodateTZ(bo.STARTTIME, 'Australia/Sydney'), 'HH24:MI')             AS "Class start time",
    TO_CHAR(((bo.stoptime - bo.starttime)/60000) * interval '1 min', 'HH24:MI') AS "Class duration",
    br.NAME                                                                     AS "Class location",
    bo.CLASS_CAPACITY                                                           AS "Class capacity",
    bo.WAITING_LIST_CAPACITY                                                    AS "Waitlist capacity"
FROM
    BOOKINGS bo
CROSS JOIN
    params
JOIN
    STAFF_USAGE su
ON
    bo.CENTER = su.BOOKING_CENTER
AND bo.ID = su.BOOKING_ID
AND su.STATE = 'ACTIVE'
JOIN
    BOOKING_RESOURCE_USAGE bru
ON
    bo.ID = bru.BOOKING_ID
AND bo.CENTER = bru.BOOKING_CENTER
AND bru.STATE != 'CANCELLED'
JOIN
    PERSONS staff
ON
    staff.CENTER = su.PERSON_CENTER
AND staff.ID = su.PERSON_ID
JOIN
    BOOKING_RESOURCES br
ON
    br.CENTER = bru.BOOKING_RESOURCE_CENTER
AND br.ID = bru.BOOKING_RESOURCE_ID
JOIN
    CENTERS c
ON
    c.ID = bo.CENTER
JOIN
    ACTIVITY ac
ON
    ac.ID = bo.ACTIVITY
    /* Activity type 'Class' only */
AND ac.activity_type = 2
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = ac.activity_group_id
WHERE
    bo.CENTER IN ($$scope$$)
AND (
        'ALL' IN ($$activity_group$$)
    OR  ag.name LIKE REPLACE($$activity_group$$, '*', '%')
)
AND (
        'ALL' IN ($$class_name$$)
    OR  bo.name LIKE REPLACE($$class_name$$, '*', '%')
)
AND (
        'ALL' IN ($$instructor_name$$)
    OR  staff.FULLNAME LIKE REPLACE($$instructor_name$$, '*', '%')
)
AND bo.STARTTIME >= params.PeriodStart
AND bo.STARTTIME <= params.PeriodEnd
AND bo.STATE IN ('ACTIVE', 'PLANNED')
ORDER BY
    c.WEB_NAME,
    "Class start date",
    "Class start time",
    bo.name;
