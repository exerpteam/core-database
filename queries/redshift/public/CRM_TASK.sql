SELECT
    t.ID     AS "ID",
    t.STATUS AS "STATUS",
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
    END AS "PERSON_ID",
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
    END                AS "ASSIGNED_PERSON_ID",
    prog.EXTERNAL_ID   AS "PROGRESS_GROUP",
    ts.EXTERNAL_ID     AS "STEP",
    t.CREATION_TIME    AS "CREATION_DATETIME",
    t.CENTER           AS "CENTER_ID",
    t.FOLLOW_UP        AS "FOLLOW_UP_DATE",
    t.SOURCE_TYPE      AS "SOURCE_TYPE",
    wf.EXTERNAL_ID     AS "WORKFLOW",
    t.title            AS "TITLE",
    t.LAST_UPDATE_TIME AS "ETS",
    CASE
        WHEN (creator.CENTER != creator.TRANSFERS_CURRENT_PRS_CENTER
                OR creator.id != creator.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = creator.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = creator.TRANSFERS_CURRENT_PRS_ID)
        ELSE creator.EXTERNAL_ID
    END                AS "CREATOR_PERSON_ID"    
FROM
    TASKS t
LEFT JOIN
    PERSONS p
ON
    p.center = t.PERSON_CENTER
    AND p.id = t.PERSON_ID
LEFT JOIN
    PERSONS staff
ON
    staff.center = t.ASIGNEE_CENTER
    AND staff.id = t.ASIGNEE_ID
LEFT JOIN
    PERSONS creator
ON
    creator.center = t.creator_center
    AND creator.id = t.creator_id
LEFT JOIN
    TASK_STEPS ts
ON
    ts.id = t.STEP_ID
LEFT JOIN
    PROGRESS prog
ON
    prog.ID = ts.PROGRESS_ID
LEFT JOIN
    WORKFLOWS wf
ON
    wf.ID = ts.WORKFLOW_ID
