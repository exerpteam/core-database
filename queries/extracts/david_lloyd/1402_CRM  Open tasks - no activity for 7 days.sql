-- This is the version from 2026-02-05
--  
SELECT
    P.center || 'p' || p.id AS "Person id",
	t.ID     AS "Task ID",
    t.STATUS AS "Task STATUS",
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
    END AS "EXTERNAL_ID",
	    p.fullname AS "NAME",
    pea.txtvalue AS "Email",
    staff.fullname AS "ASSIGNEE",
    ts.EXTERNAL_ID     AS "STEP_ID",
    ts.NAME            AS "STEP",
    TO_CHAR(longtodateC(t.CREATION_TIME ,T.center), 'dd-mm-yyyy') AS "CREATION DATE",
    creator.fullname AS "CREATED BY",
    t.CENTER           AS "CENTER_ID",
    TO_CHAR(T.FOLLOW_UP, 'DD-MM-YYYY') AS "FOLLOW UP DATE",
    t.SOURCE_TYPE      AS "SOURCE TYPE",
    wf.NAME              AS "WORKFLOW",
    t.title            AS "TASK TITLE",
    TO_CHAR(longtodateC( t.LAST_UPDATE_TIME ,T.center), 'dd-mm-yyyy') AS "LAST UPDATED"
  
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
    PERSON_EXT_ATTRS    PEA
    ON
    p.center = pea.personcenter
    AND
    p.id = pea.personid
    AND
    pea.name = '_eClub_Email'
LEFT JOIN
    PERSONS creator
ON
    creator.center = t.creator_center
    AND
    creator.id = t.creator_id
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
WHERE
    p.center IN (:scope)
    AND wf.external_id IN (:workflow)
   AND longtodateC(t.LAST_UPDATE_TIME, t.center) < (CURRENT_DATE - INTERVAL '7 days')
AND
t.status != 'CLOSED'
