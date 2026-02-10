-- The extract is extracted from Exerp on 2026-02-08
-- Prel variant to get all changes associated with a customer out as log files
SELECT
    t.ID                              task_id,
    tl.ID                             LOG_ID,
    tld.ID                            LOG_DETAILS_ID,
    longToDate(tl.ENTRY_TIME) log_entry_time,
    ta.NAME                           TASK_ACTION,
    ts.NAME                           TASK_STEP,
    tl.TASK_STATUS,
    tld.TYPE                DETAILS_TYPE,
    tld.VALUE               DETAILS_VALUE,
    p.CENTER || 'p' || p.ID prospect_pid,
    p.FULLNAME              prospect_name,
    t.ASIGNEE_CENTER,
    ass.CENTER || 'p' || ass.ID employee_pid,
    ass.FULLNAME                employee_name
FROM
    TASKS t
JOIN
    TASK_LOG tl
ON
    tl.TASK_ID = t.ID
LEFT JOIN
    TASK_LOG_DETAILS tld
ON
    tld.TASK_LOG_ID = tl.ID
LEFT JOIN
    TASK_ACTIONS ta
ON
    ta.ID = tl.TASK_ACTION_ID
LEFT JOIN
    TASK_STEPS ts
ON
    ts.ID = tl.TASK_STEP_ID
JOIN
    PERSONS p
ON
    p.CENTER = t.PERSON_CENTER
    AND p.ID = t.PERSON_ID
LEFT JOIN
    PERSONS ass
ON
    ass.CENTER = t.ASIGNEE_CENTER
    AND ass.ID = t.ASIGNEE_ID
WHERE
    (
        p.CENTER,p.ID) IN ($$pid$$)
ORDER BY
    t.ID ,
    tl.ID ,
    tld.ID