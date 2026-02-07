WITH
    PARAMS AS
    (
        SELECT
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE, '2019-01-01 HH24:MI' ), 'Europe/Rome') - 1000*60*
            60*24*7 AS bigint) AS STARTTIME,
            CAST(datetolongtz(TO_CHAR(CURRENT_DATE, '2019-12-31 HH24:MI' ), 'Europe/Rome') AS bigint)
            AS ENDTIME
    )
SELECT
    COALESCE(t."ClassDate",'(Italy) Total') AS "Date",
    "APP Booking",
    "WEB Booking"
FROM
    (
        SELECT
            TO_CHAR(longtodatetz(par.CREATION_TIME, 'Europe/Rome'),'YYYY-MM-DD') AS "ClassDate",
            SUM(
                CASE
                    WHEN par.USER_INTERFACE_TYPE = 6
                    THEN 1
                    ELSE 0
                END) AS "APP Booking",
            SUM(
                CASE
                    WHEN par.USER_INTERFACE_TYPE = 2
                    THEN 1
                    ELSE 0
                END) AS "WEB Booking"
        FROM
            PARTICIPATIONS par,
            PARAMS,
            CENTERS c
        WHERE
            (
                par.STATE IN ('PARTICIPATION',
                              'BOOKED')
            OR  (
                    par.STATE = 'CANCELLED'
                AND par.CANCELATION_REASON <> 'USER'))
        AND c.ID = par.CENTER
        AND c.country = 'IT'
        AND PARAMS.STARTTIME <= par.CREATION_TIME
        AND PARAMS.ENDTIME > par.CREATION_TIME
        AND par.user_interface_type IN (2,6)
        GROUP BY
            grouping sets ( (TO_CHAR(longtodatetz(par.CREATION_TIME, 'Europe/Rome'),'YYYY-MM-DD')),
            ()) ) t