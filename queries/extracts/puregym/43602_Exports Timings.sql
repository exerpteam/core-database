SELECT
    TO_CHAR(TRUNC(longtodatetz(op.START_TIME,'Europe/London')),'yyyy-MM-dd')          AS EXPORT_DATE,
    TO_CHAR(longtodatetz(MIN(exp.EXPORT_TIME),'Europe/London'), 'yyyy-MM-dd hh24:mi')    FIRST_EXPORT_TIME,
    TO_CHAR(longtodatetz(MAX(exp.EXPORT_TIME),'Europe/London'), 'yyyy-MM-dd hh24:mi')    LAST_EXPORT_TIME
FROM
    PUREGYM.EXCHANGED_FILE_OP op
JOIN
    PUREGYM.EXCHANGED_FILE ef
ON
    op.EXCHANGED_FILE_ID = ef.id
JOIN
    PUREGYM.EXTRACT ex
ON
    ex.ID = ef.AGENCY
    AND ef.SERVICE = 'Extract'
JOIN
    PUREGYM.EXCHANGED_FILE_EXP exp
ON
    exp.EXCHANGED_FILE_ID = ef.id
JOIN
    PUREGYM.EXCHANGED_FILE_SC sc
ON
    ef.SCHEDULE_ID = sc.id
WHERE
    op.EMPLOYEE_CENTER IS NULL
    AND op.START_TIME BETWEEN $$START_DATE$$ AND $$END_DATE$$
    AND sc.SCHEDULE = 'daily'
GROUP BY
    TRUNC(longtodatetz(op.START_TIME,'Europe/London'))
ORDER BY
    TRUNC(longtodatetz(op.START_TIME,'Europe/London')) DESC