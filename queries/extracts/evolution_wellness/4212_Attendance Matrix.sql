WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromDateLong,
            CAST(datetolongC(TO_CHAR(TO_DATE((:toDate), 'YYYY-MM-DD') + interval '1 day',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS toDateLong,
            --TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '10 day' AS prev_day,
            c.id   AS centerid,
            c.name AS centername
        FROM
            centers c
    )
    ,
    person_types AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    t1.*,
                    CASE
                        WHEN t1.product_name LIKE '%Employee'
                        THEN 'Staff'
                        WHEN t1.product_name LIKE '%Complimentary'
                        THEN 'Complimentary'
                        ELSE 'Member'
                    END AS person_type
                FROM
                    (
                        SELECT
                            pu.person_center,
                            pu.person_id,
                            pu.target_start_time,
                            pr.name AS product_name
                        FROM
                            privilege_usages pu
                        JOIN
                            params par
                        ON
                            par.centerid = pu.target_center
                        JOIN
                            subscriptions s
                        ON
                            s.center = pu.source_center
                        AND s.id = pu.source_id
                        AND pu.source_subid IS NULL
                        JOIN
                            subscriptiontypes st
                        ON
                            st.center = s.subscriptiontype_center
                        AND st.id = s.subscriptiontype_id
                        JOIN
                            products pr
                        ON
                            pr.center = st.center
                        AND pr.id = st.id
                        WHERE
                            pu.privilege_type = 'BOOKING'
                        AND pu.target_service = 'Attend'
                        AND pu.target_start_time BETWEEN par.fromDateLong AND par.toDateLong
                        UNION ALL
                        SELECT
                            pu.person_center,
                            pu.person_id,
                            pu.target_start_time,
                            prod.name AS product_name
                        FROM
                            privilege_usages pu
                        JOIN
                            params par
                        ON
                            par.centerid = pu.target_center
                        JOIN
                            clipcards cc
                        ON
                            cc.center = pu.source_center
                        AND cc.id = pu.source_id
                        AND cc.subid = pu.source_subid
                        JOIN
                            products prod
                        ON
                            prod.center = cc.center
                        AND prod.id = cc.id
                        WHERE
                            pu.privilege_type = 'BOOKING'
                        AND pu.target_service = 'Attend'
                        AND pu.target_start_time BETWEEN par.fromDateLong AND par.toDateLong) t1
                JOIN
                    persons p
                ON
                    p.center = t1.person_center
                AND p.id = t1.person_id ) t2
        WHERE
            t2.person_type IN (:persontype)
    )
    ,
    total_checkins AS
    (
        SELECT
            t.*,
            COUNT(*) AS total_count
        FROM
            (
                SELECT
                    ch.checkin_center,
                    (longtodateC(ch.checkin_time, ch.checkin_center)):: DATE AS checkin_date
                FROM
                    checkins ch
                JOIN
                    params par
                ON
                    par.centerid = ch.checkin_center
                JOIN
                person_types pt
                ON
                pt.person_center = ch.person_center
                AND pt.person_id = ch.person_id
                AND pt.target_start_time = ch.checkin_time
                WHERE
                        ch.checkin_failed_reason IS NULL
                    /*ch.checkin_time BETWEEN par.fromDateLong AND par.toDateLong
                AND ch.checkin_result != 3 */ ) t
        GROUP BY
            t.checkin_center,
            t.checkin_date
        ORDER BY
            t.checkin_center,
            t.checkin_date
    )
    ,
    check_ins AS
    (
        SELECT
            ch.checkin_center AS center,
            --TO_CHAR(ch.checkin_time, 'Day')              AS weekday,
            (longtodateC(ch.checkin_time, ch.checkin_center)):: DATE         AS DATE,
            TO_CHAR(longtodateC(ch.checkin_time, ch.checkin_center), 'HH24') AS hour
        FROM
            checkins ch
        JOIN
            params par
        ON
            par.centerid = ch.checkin_center
        JOIN
                person_types pt
                ON
                pt.person_center = ch.person_center
                AND pt.person_id = ch.person_id
                AND pt.target_start_time = ch.checkin_time
                WHERE
                        ch.checkin_failed_reason IS NULL
                    /*ch.checkin_time BETWEEN par.fromDateLong AND par.toDateLong
                AND ch.checkin_result != 3 */
        ORDER BY
            ch.checkin_center,
            DATE,
            hour
    )
    ,
    total_checkins_period AS
    (
        SELECT
            ch.checkin_center,
            COUNT(*) AS total_count
        FROM
            checkins ch
        JOIN
            params par
        ON
            par.centerid = ch.checkin_center
        JOIN
                person_types pt
                ON
        pt.person_center = ch.person_center
        AND pt.person_id = ch.person_id
        AND pt.target_start_time = ch.checkin_time
        WHERE
                        ch.checkin_failed_reason IS NULL
                   /* ch.checkin_time BETWEEN par.fromDateLong AND par.toDateLong
                AND ch.checkin_result != 3 */
        GROUP BY
            ch.checkin_center
        ORDER BY
            ch.checkin_center
    )
    ,
    dates AS
    (
        SELECT
            c.id,
            c.name,
            date_trunc('day', dd):: DATE AS swipe_date
        FROM
            centers c,
            generate_series ( CAST((:fromDate) AS TIMESTAMP) , CAST((:toDate) AS TIMESTAMP) ,
            '1 day'::interval) dd
        ORDER BY
            c.id
    )
SELECT
    *
FROM
    (
        SELECT
            --  da.id,
            da.name,
            TO_CHAR(da.swipe_date, 'DD-MM-YYYY') AS DATE,
            COUNT(
                CASE
                    WHEN che.hour IN ('00',
                                      '01',
                                      '02',
                                      '03',
                                      '04',
                                      '05')
                    THEN 1
                END) AS "<6 AM",
            COUNT(
                CASE
                    WHEN che.hour = '06'
                    THEN 1
                END) AS "6-7 AM",
            COUNT(
                CASE
                    WHEN che.hour = '07'
                    THEN 1
                END) AS "7-8 AM",
            COUNT(
                CASE
                    WHEN che.hour = '08'
                    THEN 1
                END) AS "8-9 AM",
            COUNT(
                CASE
                    WHEN che.hour = '09'
                    THEN 1
                END) AS "9-10 AM",
            COUNT(
                CASE
                    WHEN che.hour = '10'
                    THEN 1
                END) AS "10-11 AM",
            COUNT(
                CASE
                    WHEN che.hour = '11'
                    THEN 1
                END) AS "11-12 AM",
            COUNT(
                CASE
                    WHEN che.hour = '12'
                    THEN 1
                END) AS "12-1 PM",
            COUNT(
                CASE
                    WHEN che.hour = '13'
                    THEN 1
                END) AS "1-2 PM",
            COUNT(
                CASE
                    WHEN che.hour = '14'
                    THEN 1
                END) AS "2-3 PM",
            COUNT(
                CASE
                    WHEN che.hour = '15'
                    THEN 1
                END) AS "3-4 PM",
            COUNT(
                CASE
                    WHEN che.hour = '16'
                    THEN 1
                END) AS "4-5 PM",
            COUNT(
                CASE
                    WHEN che.hour = '17'
                    THEN 1
                END) AS "5-6 PM",
            COUNT(
                CASE
                    WHEN che.hour = '18'
                    THEN 1
                END) AS "6-7 PM",
            COUNT(
                CASE
                    WHEN che.hour = '19'
                    THEN 1
                END) AS "7-8 PM",
            COUNT(
                CASE
                    WHEN che.hour = '20'
                    THEN 1
                END) AS "8-9 PM",
            COUNT(
                CASE
                    WHEN che.hour = '21'
                    THEN 1
                END) AS "9-10 PM",
            COUNT(
                CASE
                    WHEN che.hour IN ('22',
                                      '23')
                    THEN 1
                END) AS ">10 PM",
            CASE
                WHEN tc.total_count IS NULL
                THEN 0
                ELSE tc.total_count
            END AS "Total"
        FROM
            dates da
        LEFT JOIN
            check_ins che
        ON
            che.center = da.id
        AND che.date = da.swipe_date
        LEFT JOIN
            total_checkins tc
        ON
            tc.checkin_center = da.id
        AND tc.checkin_date = da.swipe_date
        WHERE
            da.id IN (:scope)
        GROUP BY
            --    da.id,
            da.name,
            da.swipe_date,
            tc.total_count
        UNION ALL
        SELECT
            --c.id,
            c.name,
            'Club Total' AS swipe_date,
            COUNT(
                CASE
                    WHEN che.hour IN ('00',
                                      '01',
                                      '02',
                                      '03',
                                      '04',
                                      '05')
                    THEN 1
                END) AS "<6 AM",
            COUNT(
                CASE
                    WHEN che.hour = '06'
                    THEN 1
                END) AS "6-7 AM",
            COUNT(
                CASE
                    WHEN che.hour = '07'
                    THEN 1
                END) AS "7-8 AM",
            COUNT(
                CASE
                    WHEN che.hour = '08'
                    THEN 1
                END) AS "8-9 AM",
            COUNT(
                CASE
                    WHEN che.hour = '09'
                    THEN 1
                END) AS "9-10 AM",
            COUNT(
                CASE
                    WHEN che.hour = '10'
                    THEN 1
                END) AS "10-11 AM",
            COUNT(
                CASE
                    WHEN che.hour = '11'
                    THEN 1
                END) AS "11-12 AM",
            COUNT(
                CASE
                    WHEN che.hour = '12'
                    THEN 1
                END) AS "12-1 PM",
            COUNT(
                CASE
                    WHEN che.hour = '13'
                    THEN 1
                END) AS "1-2 PM",
            COUNT(
                CASE
                    WHEN che.hour = '14'
                    THEN 1
                END) AS "2-3 PM",
            COUNT(
                CASE
                    WHEN che.hour = '15'
                    THEN 1
                END) AS "3-4 PM",
            COUNT(
                CASE
                    WHEN che.hour = '16'
                    THEN 1
                END) AS "4-5 PM",
            COUNT(
                CASE
                    WHEN che.hour = '17'
                    THEN 1
                END) AS "5-6 PM",
            COUNT(
                CASE
                    WHEN che.hour = '18'
                    THEN 1
                END) AS "6-7 PM",
            COUNT(
                CASE
                    WHEN che.hour = '19'
                    THEN 1
                END) AS "7-8 PM",
            COUNT(
                CASE
                    WHEN che.hour = '20'
                    THEN 1
                END) AS "8-9 PM",
            COUNT(
                CASE
                    WHEN che.hour = '21'
                    THEN 1
                END) AS "9-10 PM",
            COUNT(
                CASE
                    WHEN che.hour IN ('22',
                                      '23')
                    THEN 1
                END) AS ">10 PM",
            CASE
                WHEN tcp.total_count IS NULL
                THEN 0
                ELSE tcp.total_count
            END AS "Total"
        FROM
            centers c
        LEFT JOIN
            check_ins che
        ON
            che.center = c.id
        LEFT JOIN
            total_checkins_period tcp
        ON
            tcp.checkin_center = c.id
        WHERE
            c.id IN (:scope)
        GROUP BY
            --c.id,
            c.name,
            tcp.total_count
        UNION ALL
        SELECT
            'Report Total' AS name,
            NULL           AS DATE,
            COUNT(
                CASE
                    WHEN che.hour IN ('00',
                                      '01',
                                      '02',
                                      '03',
                                      '04',
                                      '05')
                    THEN 1
                END) AS "<6 AM",
            COUNT(
                CASE
                    WHEN che.hour = '06'
                    THEN 1
                END) AS "6-7 AM",
            COUNT(
                CASE
                    WHEN che.hour = '07'
                    THEN 1
                END) AS "7-8 AM",
            COUNT(
                CASE
                    WHEN che.hour = '08'
                    THEN 1
                END) AS "8-9 AM",
            COUNT(
                CASE
                    WHEN che.hour = '09'
                    THEN 1
                END) AS "9-10 AM",
            COUNT(
                CASE
                    WHEN che.hour = '10'
                    THEN 1
                END) AS "10-11 AM",
            COUNT(
                CASE
                    WHEN che.hour = '11'
                    THEN 1
                END) AS "11-12 AM",
            COUNT(
                CASE
                    WHEN che.hour = '12'
                    THEN 1
                END) AS "12-1 PM",
            COUNT(
                CASE
                    WHEN che.hour = '13'
                    THEN 1
                END) AS "1-2 PM",
            COUNT(
                CASE
                    WHEN che.hour = '14'
                    THEN 1
                END) AS "2-3 PM",
            COUNT(
                CASE
                    WHEN che.hour = '15'
                    THEN 1
                END) AS "3-4 PM",
            COUNT(
                CASE
                    WHEN che.hour = '16'
                    THEN 1
                END) AS "4-5 PM",
            COUNT(
                CASE
                    WHEN che.hour = '17'
                    THEN 1
                END) AS "5-6 PM",
            COUNT(
                CASE
                    WHEN che.hour = '18'
                    THEN 1
                END) AS "6-7 PM",
            COUNT(
                CASE
                    WHEN che.hour = '19'
                    THEN 1
                END) AS "7-8 PM",
            COUNT(
                CASE
                    WHEN che.hour = '20'
                    THEN 1
                END) AS "8-9 PM",
            COUNT(
                CASE
                    WHEN che.hour = '21'
                    THEN 1
                END) AS "9-10 PM",
            COUNT(
                CASE
                    WHEN che.hour IN ('22',
                                      '23')
                    THEN 1
                END) AS ">10 PM",
            COUNT(*) AS TOTAL
        FROM
            check_ins che
        WHERE
            che.center IN (:scope) ) t
ORDER BY
    t.name,
    t.date