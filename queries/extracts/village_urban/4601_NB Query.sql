-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    tc.NAME,
    tc.WORKFLOW_ID,
    longtodatec(tl.entry_time,8120) AS entry_time_date,
    t.*,
    tl.*,
    tld.*,
    tuc.*
FROM

    VU.TASKS t
JOIN
    VU.TASK_LOG tl
ON
    t.id =tl.task_id
JOIN
    VU.TASK_LOG_DETAILS tld
ON
    tld.TASK_LOG_ID = tl.id
JOIN
    VU.TASK_USER_CHOICES tuc
ON
    tuc.ID = t.LAST_CHOICE_ID
JOIN
    VU.TASK_CATEGORIES tc
ON
    tc.ID = t.TASK_CATEGORY_ID
WHERE
    t.PERSON_CENTER = 8120
    AND t.PERSON_ID = 12423
    --AND t.PERSON_ID = 13072
ORDER BY
    tl.ENTRY_TIME DESC