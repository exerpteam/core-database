SELECT
    tl.ID           AS "ID",
    ta.EXTERNAL_ID  AS "ACTION",
    tl.ENTRY_TIME   AS "ENTRY_DATETIME",
    t.PERSON_CENTER AS "CENTER_ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END              AS "PERSON_ID",
    t.ID             AS "TASK_ID",
    prog.EXTERNAL_ID AS "PROGRESS_GROUP",
    CASE
        WHEN (staff.CENTER != staff.TRANSFERS_CURRENT_PRS_CENTER
                OR staff.id != staff.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = staff.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = staff.TRANSFERS_CURRENT_PRS_ID)
        ELSE staff.EXTERNAL_ID
    END                   AS "EMPLOYEE_PERSON_ID",
    tld_user_choice.VALUE AS "USER_CHOICE",
    ts.name               AS "FROM_STEP",
    tl.ENTRY_TIME         AS "ETS"
FROM
    TASK_ACTIONS ta
JOIN
    TASK_LOG tl
ON
    tl.TASK_ACTION_ID = ta.id
JOIN
    TASK_STEPS ts
ON
    ts.ID = tl.TASK_STEP_ID
LEFT JOIN
    PROGRESS prog
ON
    prog.ID = ts.PROGRESS_ID
JOIN
    TASKS t
ON
    t.ID = tl.TASK_ID
JOIN
    PERSONS p
ON
    p.center = t.PERSON_CENTER
    AND p.id = t.PERSON_ID
LEFT JOIN
    PERSONS staff
ON
    staff.center = tl.EMPLOYEE_CENTER
    AND staff.id = tl.EMPLOYEE_ID
LEFT JOIN
    TASK_LOG_DETAILS tld_user_choice
ON
    tld_user_choice.TASK_LOG_ID = tl.id
    AND tld_user_choice.NAME = 'RequirementType.USER_CHOICE'
