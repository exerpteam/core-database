SELECT
    NULL                    CENTER,
    t.ID                    ID,
    NULL                    SUBID,
    p.CENTER || 'p' || p.ID PERSONKEY,
    p.FIRSTNAME             FIRSTNAME,
    p.LASTNAME              LASTNAME
FROM
    TASK_LOG tl
JOIN
    TASK_LOG_DETAILS tld
ON
    tld.TASK_LOG_ID = tl.ID --and tld.NAME = 'RequirementType.USER_CHOICE'
JOIN
    TASKS t
ON
    t.ID = tl.TASK_ID
    AND tld.VALUE = 'No answer'
JOIN
    PERSONS p
ON
    p.CENTER = t.PERSON_CENTER
    AND p.ID = t.PERSON_ID
WHERE
    t.TYPE_ID = 1
GROUP BY
    p.CENTER,
    p.ID,
    t.CREATION_TIME,
    p.FIRSTNAME,
    p.LASTNAME,
    t.ID,
    NULL
HAVING
    COUNT(tld.ID) > 4
    OR t.CREATION_TIME < dateToLong(TO_CHAR(SYSDATE-2,'YYYY-MM-DD') || ' 00:00')