SELECT
    c.id,
    c.NAME,
    a.NAME as "Regional manager",
    to_char(c.STARTUPDATE, 'DD-MM-YYYY') as "Open Date",
    
    ROUND(AVG(SYSDATE - p.LAST_ACTIVE_START_DATE),2) AS "Average Length Days",
    ROUND(AVG(SYSDATE - p.LAST_ACTIVE_START_DATE)/30,2) AS "Average Length Months"
FROM
    PUREGYM.PERSONS p
JOIN
    PUREGYM.CENTERS c
ON
    p.CENTER = c.id
JOIN
    AREA_CENTERS AC
ON
    C.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
WHERE
    p.STATUS IN (1,3)
    and p.CENTER in (:scope)
GROUP BY
    c.id,
    c.NAME,
    c.STARTUPDATE,
    a.NAME
UNION
SELECT
    NULL,
    'total',
    null,
    null,
    ROUND(AVG(SYSDATE - p.LAST_ACTIVE_START_DATE),2) AS "Average Length Days",
    ROUND(AVG(SYSDATE - p.LAST_ACTIVE_START_DATE)/30,2) AS "Average Length Months"
FROM
    persons p
WHERE
    p.STATUS IN (1,3)
    and p.CENTER in (:scope)
ORDER BY
    1