-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            $$StartDate$$                      AS FromDate,
            ($$EndDate$$ + 86400 * 1000) - 1 AS ToDate
        FROM
            dual
    )
SELECT
    classcount.classdate                                                       AS "Class Date",
    classcount.TotalCount                                                      AS "Total Rides Taken (Day)",
    classcount.UniqueCount                                                     AS "Rides Taken Unique Customers",
    classcount.RepeatCount                                                     AS "Rides Taken Repeat Customers",
    ROUND((classcount.UniqueCount/NULLIF(classcount.TotalCount,0))*100,2)      AS "Unique Customers Ratio%",
    ROUND((classcount.RepeatCount/NULLIF(classcount.TotalCount,0))*100,2)      AS "Repeat Customers Ratio%",
    classcount.PerformanceCount                                                AS "Total Performance Class (Day)",
    classcount.SignatureCount                                                  AS "Total Signature Class (Day)",
    ROUND((classcount.PerformanceCount/NULLIF(classcount.TotalCount,0))*100,2) AS "Performance Class Ratio%",
    ROUND((classcount.SignatureCount/NULLIF(classcount.TotalCount,0))*100,2)   AS "Signature Class Ratio%"
FROM
    (
        SELECT
            classcenter.classdate,
            SUM(
                CASE
                    WHEN classcenter.name = 'Performance'
                    THEN 1
                    ELSE 0
                END )AS PerformanceCount,
            SUM(
                CASE
                    WHEN classcenter.name = 'Signature'
                    THEN 1
                    ELSE 0
                END )AS SignatureCount,
            SUM(
                CASE
                    WHEN classcenter.name = 'Signature'
                        OR classcenter.name = 'Performance'
                    THEN 1
                    ELSE 0
                END )AS TotalCount,
            SUM(
                CASE
                    WHEN classcenter.flag = 'FIRST'
                    THEN 1
                    ELSE 0
                END )AS UniqueCount,
            SUM(
                CASE
                    WHEN classcenter.flag = 'REPEAT'
                    THEN 1
                    ELSE 0
                END )AS RepeatCount
        FROM
            (
                SELECT
                    TO_CHAR(longtodatetz(class.STARTTIME,'Europe/London'),'yyyy-MM-dd') classdate,
                    class.name,
                    class.flag
                FROM
                    (
                        SELECT
                            bo.center,
                            bo.STARTTIME,
                            cg.name,
                            CASE
                                WHEN FIRST_VALUE(pa.start_time) OVER (PARTITION BY pa.participant_center, pa.participant_id ORDER BY pa.start_time RANGE UNBOUNDED PRECEDING) = pa.start_time
                                THEN 'FIRST'
                                ELSE 'REPEAT'
                            END AS flag
                        FROM
                            BOOKINGS bo
                        JOIN
                            ACTIVITY ac
                        ON
                            ac.ID = bo.ACTIVITY
                        JOIN
                            puregym.colour_groups cg
                        ON
                            cg.id = ac.colour_group_id
                        JOIN
                            PARTICIPATIONS pa
                        ON
                            pa.booking_center = bo.center
                            AND pa.booking_id = bo.id
                        JOIN
                            persons p
                        ON
                            pa.state = 'PARTICIPATION'
                            AND p.id = pa.participant_id
                            AND p.center = pa.participant_center
                        WHERE
                            bo.STATE='ACTIVE'
                            AND cg.name IN ('Performance',
                                            'Signature')
                            AND p.sex IN ($$Sex$$) ) class
                CROSS JOIN
                    params
                WHERE
                    class.STARTTIME>= params.FromDate
                    AND class.STARTTIME<= params.ToDate
                    AND class.CENTER IN ($$Scope$$) )classcenter
        GROUP BY
            classcenter.classdate)classcount