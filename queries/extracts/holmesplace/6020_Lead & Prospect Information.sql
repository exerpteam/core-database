-- The extract is extracted from Exerp on 2026-02-08
--  


SELECT
    c.shortname     AS "Club",
    MC              AS MC,
    (LEAD) AS "Total Leads",
    (HOT + HOT_OVERDUE+WARM + WARM_OVERDUE+FUTURE +
    FUTURE_OVERDUE+COLD + COLD_OVERDUE )           AS "Total Prospects" ,
    (HOT + HOT_OVERDUE)                                        AS "Prospects Hot",
    ROUND( 100* (HOT_OVERDUE)/(0.0001+(HOT + HOT_OVERDUE))) || '%'AS
    "Hot overdue",
    (WARM + WARM_OVERDUE)                                     AS "Prospects Warm",
    ROUND( 100* (WARM_OVERDUE)/(0.0001+(WARM + WARM_OVERDUE))) || '%'AS
    "Warm overdue",
    (FUTURE + FUTURE_OVERDUE) AS "Prospects Future",
    ROUND( 100* (FUTURE_OVERDUE)/(0.0001+(FUTURE + FUTURE_OVERDUE))) ||
    '%'                                                                         AS "Future overdue",
    (COLD + COLD_OVERDUE)                                     AS "Prospects Cold",
    ROUND( 100* (COLD_OVERDUE)/(0.0001+(COLD + COLD_OVERDUE))) || '%'AS
    "Cold overdue"
FROM
    (
        SELECT
            center,
            MC,
            SUM(
                CASE
                    WHEN category = 'LEAD'
                    THEN 1
                    ELSE 0
                END) AS LEAD,
            SUM(
                CASE
                    WHEN category = 'LEAD_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS LEAD_OVERDUE,
            SUM(
                CASE
                    WHEN category = 'HOT'
                    THEN 1
                    ELSE 0
                END) AS HOT,
            SUM(
                CASE
                    WHEN category = 'HOT_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS HOT_OVERDUE,
            SUM(
                CASE
                    WHEN category = 'WARM'
                    THEN 1
                    ELSE 0
                END) AS WARM,
            SUM(
                CASE
                    WHEN category = 'WARM_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS WARM_OVERDUE,
            SUM(
                CASE
                    WHEN category = 'COLD'
                    THEN 1
                    ELSE 0
                END) AS COLD,
            SUM(
                CASE
                    WHEN category = 'COLD_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS COLD_OVERDUE,
            SUM(
                CASE
                    WHEN category = 'FUTURE'
                    THEN 1
                    ELSE 0
                END) AS FUTURE,
            SUM(
                CASE
                    WHEN category = 'FUTURE_OVERDUE'
                    THEN 1
                    ELSE 0
                END) AS FUTURE_OVERDUE
        FROM
            (
                SELECT
                    t.center,
                    COALESCE( emp.FULLNAME,'Unassigned') AS MC,
                    CASE
                        WHEN (p.status = 0)
                        THEN 'LEAD'
                        WHEN (p.status = 6 )
                        THEN tg.EXTERNAL_ID ||
                            CASE
                                WHEN (t.status = 'OVERDUE')
                                THEN '_OVERDUE'
                                ELSE ''
                            END
                        ELSE 'OTHER'
                    END  AS Category,
                    t.id AS id
                FROM
                    HP.tasks t
                JOIN
                    HP.TASK_CATEGORIES tg
                ON
                    t.TASK_CATEGORY_ID = tg.id
                JOIN
                    HP.persons p
                ON
                    p.center = t.PERSON_CENTER
                AND p.id = t.person_id
                LEFT JOIN
                    HP.persons emp
                ON
                    emp.center = t.ASIGNEE_CENTER
                AND emp.id = t.ASIGNEE_ID
                WHERE
                    TYPE_ID = 200
                AND t.center IN (:scope)
                AND
                    -- LEAD: 0 , PROSPECT: 6
                    p.STATUS IN (0,6)
                AND t.STATUS NOT IN ('CLOSED',
                                     'DELETED') ) x
        GROUP BY
            center,
            MC ) lc
JOIN
    HP.centers c
ON
    c.id = lc.center
ORDER BY
    center,
    MC