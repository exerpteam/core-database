-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-9002
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$FromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS fromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$ToDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS toDate
        FROM
            centers c
    )
SELECT
    Club                                                AS "Club",
    StaffName                                           AS "Staff Name",
    ClassStartDate                                      AS "Date",
    ROUND((CAST(SUM(ClassDuration) AS DECIMAL)/ 60), 2) AS "Hours Worked"
FROM
    (
        SELECT
            c.shortname                                                       AS Club,
            staff.FULLNAME                                                    AS StaffName,
            b.NAME                                                            AS ClassName,
            TO_CHAR(longtodateTZ(b.STARTTIME, 'Europe/Berlin'), 'DD-MM-YYYY') AS ClassStartDate,
            TO_CHAR(longtodateTZ(b.STARTTIME, 'Europe/Berlin'), 'HH24:MI')    AS ClassStartTime,
            TO_CHAR(longtodateTZ(b.stoptime, 'Europe/Berlin'), 'DD-MM-YYYY')  AS ClassStopDate,
            TO_CHAR(longtodateTZ(b.stoptime, 'Europe/Berlin'), 'HH24:MI')     AS ClassStopTime,
            (b.stoptime - b.starttime)/(1000*60)                              AS ClassDuration
        FROM
            bookings b
        JOIN
            PARAMS param
        ON
            param.id = b.center
        JOIN
            activity ac
        ON
            ac.ID = b.ACTIVITY
            /* Only staff booking activity */
            AND ac.activity_type in (6, 4)
        JOIN
            activity_group ag
        ON
            ag.ID = ac.activity_group_id
            AND ag.name = 'Staff roster'
        JOIN
            STAFF_USAGE su
        ON
            b.CENTER = su.BOOKING_CENTER
            AND b.ID = su.BOOKING_ID
            AND su.STATE = 'ACTIVE'
        JOIN
            PERSONS staff
        ON
            staff.CENTER = su.PERSON_CENTER
            AND staff.ID = su.PERSON_ID
        JOIN
            CENTERS c
        ON
            c.ID = b.CENTER
        WHERE
            b.center IN ($$Scope$$)
            AND b.CREATION_TIME BETWEEN param.fromDate AND param.toDate
            AND b.STATE = 'ACTIVE') book
GROUP BY
    Club ,
    StaffName ,
    ClassStartDate