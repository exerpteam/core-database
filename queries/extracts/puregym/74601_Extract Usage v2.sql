SELECT
    t2.EXTRACT_ID,
    t2."Extract Name",
    COUNT(*) AS "Number of usage",
    t2."Last Used Time",
    t2."Employee Name",
    t2."Employee ID",
    t2."Person ID"
FROM
    (
        SELECT
            t.EXTRACT_ID,
            e.name                           AS "Extract Name",
            longtodateC(t.TIME, 100)         AS "Last Used Time",
            p.FIRSTNAME || ' ' || p.LASTNAME AS "Employee Name",
            CASE
                WHEN t.EMPLOYEE_CENTER IS NOT NULL
                THEN t.EMPLOYEE_CENTER||'emp'||t.EMPLOYEE_ID
            END AS "Employee ID",
            CASE
                WHEN em.PERSONCENTER IS NOT NULL
                THEN em.PERSONCENTER||'p'||em.PERSONID
            END AS "Person ID"
        FROM
            (
                SELECT
                    eu.*,
                    rank() over (partition BY eu.extract_id ORDER BY eu.TIME DESC) AS rnk
                FROM
                    extract_usage eu ) t
        JOIN
            extract e
        ON
            t.EXTRACT_ID = e.ID
        LEFT JOIN
            EMPLOYEES em
        ON
            em.CENTER = t.EMPLOYEE_CENTER
        AND em.ID = t.EMPLOYEE_ID
        LEFT JOIN
            persons p
        ON
            em.personcenter = p.center
        AND em.personid = p.id
        WHERE
            rnk = 1
        AND e.blocked = 0
        AND t.TIME > :Last_Usage_Date ) t2
LEFT JOIN
    extract_usage eu
ON
    t2.extract_id = eu.extract_id
GROUP BY
    t2.EXTRACT_ID,
    t2."Extract Name",
    t2."Employee Name",
    t2."Last Used Time",
    t2."Employee ID",
    t2."Person ID"