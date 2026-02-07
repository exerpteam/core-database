SELECT
    final.*
FROM
    (
        WITH
            HOURS_OPENED AS
            (
                SELECT
                    T2.*,
                    CHECKIN_CENTER                                                   AS CENTERID,
                    (endtime-to_time)                                                      AS hours,
                    ROUND(CAST(FLOOR(extract(epoch FROM (endtime-to_time)))/3600 AS NUMERIC),2) AS
                    hours_OPENED
                FROM
                    (
                        SELECT
                            checkin_center,
                            longtodateC(MIN(checkin_time),checkin_center) AS to_time,
                            longtodateC(MAX(checkin_time),checkin_center) AS endtime,
                            START_DATETIME,
                            datetoday
                        FROM
                            (
                                WITH
                                    params AS
                                    (
                                        SELECT
                                            c.id   AS CENTERID,
                                            c.name AS centername,
                                            CAST(datetolongc(TO_CHAR(to_date($$fromdate$$,
                                            'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id
                                            ) AS bigint) AS FROM_DATE,
                                            CAST(datetolongc(TO_CHAR(to_date($$todate$$,
                                            'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id
                                            ) + (24*3600*1000) - 1 AS bigint)            AS TO_DATE,
                                            to_date(TO_CHAR(now(),'yyyy-mm-dd'),'yyyy-mm-dd') AS
                                            datetoday
                                        FROM
                                            centers c
                                        WHERE
                                            id IN ($$scope$$)
                                    )
                                SELECT
                                    chk.checkin_center,
                                    chk.checkin_time,
                                    to_date(TO_CHAR(longtodatec(chk.checkin_time,chk.checkin_center
                                    ), 'YYYY-MM-DD HH24:MI') ,'yyyy-mm-dd') AS START_DATETIME,
                                    datetoday
                                FROM
                                    checkins chk
                                JOIN
                                    params
                                ON
                                    centerid=chk.checkin_center
                                AND chk.checkin_time BETWEEN from_date AND to_date)t
                        GROUP BY
                            checkin_center,
                            START_DATETIME,
                            datetoday)T2
                WHERE
                    datetoday!=START_DATETIME
            )
            ,
            RESOURCE_USAGE AS
            (
                SELECT
                    centername,
                    CENTERID,
                    START_DATETIME,
                    day_of_week,
                    resource_name,
                    ROUND(SUM(duration)/60, 2) AS hours_used_per_day
                FROM
                    (
                        SELECT
                            START_DATETIME,
                            CENTERID,
                            TO_CHAR(START_DATETIME,'Day') AS day_of_week,
                            centername,
                            duration,
                            resource_name
                        FROM
                            (
                                WITH
                                    params AS
                                    (
                                        SELECT
                                            c.id   AS CENTERID,
                                            c.name AS centername,
                                            CAST(datetolongc(TO_CHAR(to_date($$fromdate$$,
                                            'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id
                                            ) AS bigint) AS FROM_DATE,
                                            CAST(datetolongc(TO_CHAR(to_date($$todate$$,
                                            'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.id
                                            ) + (24*3600*1000) - 1 AS bigint) AS TO_DATE
                                        FROM
                                            centers c
                                        WHERE
                                            id IN ($$scope$$)
                                    )
                                SELECT
                                    CENTERID,
                                    centername,
                                    longtodateC(b.starttime,b.center) AS bk_start,
                                    to_date(TO_CHAR(longtodatec(b.STARTTIME,b.center),
                                    'YYYY-MM-DD HH24:MI'),'yyyy-mm-dd') AS START_DATETIME,
                                    (b.stoptime-b.starttime)/(60*1000)  AS duration,
                                    br.name                             AS resource_name
                                FROM
                                    booking_resources br
                                JOIN
                                    params
                                ON
                                    centerid=br.center
                                AND br.state = 'ACTIVE'
                                JOIN
                                    booking_resource_usage bru
                                ON
                                    br.center = bru.booking_resource_center
                                AND br.id=bru.booking_resource_id
                                AND BRU.STATE NOT IN ('CANCELLED')
                                JOIN
                                    bookings b
                                ON
                                    bru.booking_center=b.center
                                AND bru.booking_id=b.id
                                AND B.STATE IN ('ACTIVE')
                                AND b.starttime BETWEEN from_date AND to_date )t)t2
                GROUP BY
                    START_DATETIME,
                    day_of_week,
                    centername,
                    resource_name,
                    CENTERID
                ORDER BY
                    2,5,3
            )
        SELECT
            RU.CENTERID,
            centername,
            RU.START_DATETIME,
            day_of_week,
            resource_name,
            hours_used_per_day,
            HO.HOURS_OPENED,
            CASE
                WHEN hours_OPENED=0
                THEN NULL
                ELSE ROUND((hours_used_per_day/HO.HOURS_OPENED)*100,2)
            END||'%'                                    AS PERCENT_USAGE,
            TO_CHAR(HO.TO_TIME,'YYYY-MM-DD HH24:MI:SS') AS earliest_time,
            TO_CHAR(HO.ENDTIME,'YYYY-MM-DD HH24:MI:SS') AS latest_time
        FROM
            HOURS_OPENED HO
        JOIN
            RESOURCE_USAGE RU
        ON
            HO.CENTERID=RU.CENTERID
        AND ho.START_DATETIME = ru.START_DATETIME )final
ORDER BY
    centerid,
    resource_name,
    start_datetime