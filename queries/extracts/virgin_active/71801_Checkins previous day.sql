-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 day',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS fromdate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),
            c.id) AS BIGINT)                                              AS todate,
            TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 day' AS prev_day,
            c.id                                                          AS centerid,
            c.name                                                        AS centername
        FROM
            centers c
        WHERE
            c.country = 'IT'
        AND c.id != 100
    )
SELECT
    t1.centerid     AS "Club Id",
    t1.centername   AS "Club Name",
    CASE t1.weekday
	WHEN 'Monday   ' THEN 'Lunedì'
	WHEN 'Tuesday' THEN 'Martedì'
	WHEN 'Tuesday ' THEN 'Martedì'
	WHEN 'Tuesday  ' THEN 'Martedì'
	WHEN 'Tuesday   ' THEN 'Martedì'
	WHEN 'Wednesday' THEN 'Mercoledì'
	WHEN 'Thursday ' THEN 'Giovedì'
	WHEN 'Friday   ' THEN 'Venerdì'
	WHEN 'Saturday ' THEN 'Sabato'
	WHEN 'Sunday   ' THEN 'Domenica'
	END as "Weekday",
    t1.date AS "Date",
    CASE t1.checkin_hour 
	WHEN '05' THEN '05-06'    
    WHEN '06' THEN '06-07'
	WHEN '07' THEN '07-08'
	WHEN '08' THEN '08-09'
	WHEN '09' THEN '09-10'
	WHEN '10' THEN '10-11'
	WHEN '11' THEN '11-12'
	WHEN '12' THEN '12-13'
	WHEN '13' THEN '13-14'
	WHEN '14' THEN '14-15'
	WHEN '15' THEN '15-16'
	WHEN '16' THEN '16-17'
	WHEN '17' THEN '17-18'
	WHEN '18' THEN '18-19'
	WHEN '19' THEN '19-20'
	WHEN '20' THEN '20-21'
	WHEN '21' THEN '21-22'
	WHEN '22' THEN '22-23'
    END AS "Hour",
    COUNT(
        CASE
            WHEN t1.visittype = 'Local'
            THEN 1
        END) AS "LocalVisits",
    COUNT(
        CASE
            WHEN t1.visittype = 'Guest'
            THEN 1
        END) AS "GuestVisits",
    COUNT(*) AS "Visits"
FROM
    (
        SELECT
            ch.checkin_center                                 AS centerid,
            c.name                                            AS centername,
            TO_CHAR(t.prev_day, 'Day')                        AS weekday,
            TO_CHAR(t.prev_day, 'dd-MM-YYYY')                 AS DATE,
            MIN(TO_CHAR(longtodate(ch.checkin_time), 'HH24')) AS checkin_hour,
            p.center                                          AS personcenter,
            p.id                                              AS personid,
            CASE
                WHEN ch.checkin_center != p.center
                THEN 'Guest'
                ELSE 'Local'
            END AS VisitType
        FROM
            persons p
        JOIN
            (
                SELECT DISTINCT
                    per.center,
                    per.id,
                    MIN(unch.checkin_time) AS checkin_time,
                    par.prev_day
                FROM
                    checkins unch
                JOIN
                    params par
                ON
                    par.centerid = unch.checkin_center
                JOIN
                    persons per
                ON
                    per.center = unch.person_center
                AND per.id = unch.person_id
                WHERE
                    unch.checkin_time >= par.fromdate
                AND unch.checkin_time < par.todate
                AND unch.checkin_result IN (1,2)
                AND per.persontype NOT IN (2,9,10)
                GROUP BY
                    per.center,
                    per.id,
                    par.prev_day) t
        ON
            t.center = p.center
        AND t.id = p.id
        JOIN
            checkins ch
        ON
            ch.person_center = t.center
        AND ch.person_id = t.id
        AND ch.checkin_time = t.checkin_time
        JOIN
            centers c
        ON
            c.id = ch.checkin_center
        GROUP BY
            ch.checkin_center,
            c.name,
            t.prev_day,
            ch.checkin_center,
            p.center,
            p.id ) t1
GROUP BY
    t1.centerid,
    t1.centername,
    t1.weekday,
    t1.date,
    t1.checkin_hour
ORDER BY
    centerid,
    checkin_hour