WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$startdate$$                    AS PeriodStart,
            ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd
    )
SELECT
    c.SHORTNAME AS "Club name",
    bo.NAME     AS "Class name",
    ag.name     AS "Class activity group",
    staff.FULLNAME AS "Instructor name",
    TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'DD-MM-YYYY')               AS "Class start date",
    TO_CHAR(longtodateC(bo.STARTTIME, bo.CENTER), 'HH24:MI')                  AS "Class start time",
    TO_CHAR(((bo.stoptime - bo.starttime)/60000) * interval '1 min', 'HH24:MI') AS "Class duration",
    br.NAME AS "Class location",
    CASE
        WHEN showup_waiting_cancel.total_booked IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_booked
    END               AS "Number of booked",
    bo.CLASS_CAPACITY AS "Class capacity",
    CASE
        WHEN showup_waiting_cancel.total_waiting IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_waiting
    END AS "Number of waitlist",
    bo.WAITING_LIST_CAPACITY AS "Waitlist capacity",
    CASE
        WHEN showup_waiting_cancel.total IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total
    END AS "Total number of bookings",
    CASE
        WHEN showup_waiting_cancel.total_cancel IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_cancel
    END AS "Number of cancelled",
    CASE
        WHEN showup_waiting_cancel.total_showup IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_showup
    END AS "Number of attended",
    CASE
        WHEN showup_waiting_cancel.total_noshow IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_noshow
    END AS "Number of no shows",
    CASE
        WHEN showup_waiting_cancel.total_anonymous IS NULL
        THEN 0
        ELSE showup_waiting_cancel.total_anonymous
    END        AS "Headcount Adjustment",
    psg.salary AS salary,
	SUM(
            CASE
                WHEN part.USER_INTERFACE_TYPE = 2
                THEN 1
                ELSE 0
            END) "Web",
    SUM(
            CASE
                WHEN part.USER_INTERFACE_TYPE = 6
                THEN 1
                ELSE 0
            END) "App - Mobile API",
    SUM(
            CASE
                WHEN part.USER_INTERFACE_TYPE = 1
                THEN 1
                ELSE 0
            END) "client"   
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
AND bru.STATE = 'ACTIVE'
join 
	participations part
	on
	part.booking_center = bo.center
	and part.booking_id = bo.id
JOIN
    PERSONS staff
ON
    staff.CENTER = su.PERSON_CENTER
AND staff.ID = su.PERSON_ID
LEFT JOIN
    PERSON_EXT_Attrs PES
ON
    staff.center = PES.Personcenter
AND staff.id = PES.PERSONID
AND PES.name = 'InstructorStatus'
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
    /* Activity type 'Class' only*/
AND ac.activity_type = 2
JOIN
    ACTIVITY_GROUP ag
ON
    ag.ID = ac.activity_group_id
LEFT JOIN
    (
        SELECT
            SUM( 1 )AS total,
            SUM(
                CASE
                    WHEN pa.state = 'PARTICIPATION'
                    THEN 1
                    ELSE 0
                END )AS total_showup,
            SUM(
                CASE
                    WHEN pa.state = 'PARTICIPATION'
                    AND pa.participant_center IS NULL
                    THEN 1
                    ELSE 0
                END )AS total_anonymous,
            SUM(
                CASE
                    WHEN pa.state = 'BOOKED'
                    AND pa.on_waiting_list = 0
                    THEN 1
                    ELSE 0
                END)AS total_booked,
            SUM(
                CASE
                    WHEN pa.state = 'BOOKED'
                    AND pa.on_waiting_list = 1
                    THEN 1
                    WHEN pa.state = 'CANCELLED'
                    AND pa.CANCELATION_REASON = 'NO_SEAT'
                    THEN 1
                    ELSE 0
                END)AS total_waiting,
            SUM(
                CASE
                    WHEN pa.state = 'CANCELLED'
                    AND pa.CANCELATION_REASON IN ('CENTER',
                                                  'BOOKING',
                                                  'USER')
                    THEN 1
                    ELSE 0
                END)AS total_cancel,
            SUM(
                CASE
                    WHEN pa.state = 'CANCELLED'
                    AND pa.CANCELATION_REASON IN ('NO_SHOW',
                                                  'USER_CANCEL_LATE')
                    THEN 1
                    ELSE 0
                END)AS total_noshow,
            pa.booking_center,
            pa.booking_id
        FROM
            participations pa
        CROSS JOIN
            params params1
        JOIN
            BOOKINGS bo1
        ON
            pa.booking_center = bo1.center
        AND pa.booking_id = bo1.id
        WHERE
            bo1.CENTER IN ($$scope$$)
        AND bo1.STARTTIME>= CAST(params1.PeriodStart AS BIGINT)
        AND bo1.STARTTIME<= CAST(params1.PeriodEnd AS BIGINT)
        AND bo1.STATE='ACTIVE'
        GROUP BY
            pa.booking_center,
            pa.booking_id )showup_waiting_cancel
ON
    showup_waiting_cancel.booking_center = bo.center
AND showup_waiting_cancel.booking_id = bo.id
LEFT JOIN
    person_staff_groups psg
ON
    psg.person_center = su.person_center
AND psg.person_id = su.person_id
AND psg.scope_type = 'C'
AND psg.scope_id = su.booking_center
AND psg.staff_group_id = 801
WHERE
    ((
            'ALL' IN ($$activity_group$$))
    OR  (
            ag.name LIKE REPLACE($$activity_group$$,'*','%')))
AND ((
            'ALL' IN ($$class_name$$))
    OR  (
            bo.name LIKE REPLACE($$class_name$$,'*','%')))
AND ((
            'ALL' IN ($$instructor_name$$))
    OR  (
            staff.FULLNAME LIKE REPLACE($$instructor_name$$,'*','%')))
AND bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
AND bo.STARTTIME<= CAST(params.PeriodEnd AS BIGINT)
AND bo.CENTER IN ($$scope$$)
AND bo.STATE='ACTIVE'
AND bo.NAME not in ('Solarium')
group by c.shortname,bo.name,ag.name,staff.fullname,bo.starttime, bo.center,bo.stoptime,br.name,showup_waiting_cancel.total_booked,
bo.class_capacity,showup_waiting_cancel.total_waiting,bo.waiting_list_capacity,showup_waiting_cancel.total,
showup_waiting_cancel.total_cancel,showup_waiting_cancel.total_showup,showup_waiting_cancel.total_noshow,
showup_waiting_cancel.total_anonymous,psg.salary,c.name
ORDER BY
    c.NAME,
    bo.starttime,
    bo.name