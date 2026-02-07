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
    p.fullname AS "LEAD_NAME",
    
    

    staff.fullname AS "ASSIGNEE",

    ts.EXTERNAL_ID     AS "STEP_ID",
    ts.NAME            AS "STEP",
    TO_CHAR(longtodateC(t.CREATION_TIME ,T.center), 'dd-mm-yyyy') AS "CREATION_DATE",
    creator.fullname AS "CREATOR",
    t.CENTER           AS "CENTER_ID",
    TO_CHAR(T.FOLLOW_UP, 'DD-MM-YYYY') AS "FOLLOW_UP",
    t.SOURCE_TYPE      AS "SOURCE_TYPE",

   wf.NAME              AS "WORKFLOW",
    t.title            AS "TITLE",
    TO_CHAR(longtodateC( t.LAST_UPDATE_TIME ,T.center), 'dd-mm-yyyy') AS "LAST_UPDATED"
  
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
 p.center IN (:SCOPE)

 and
 T.STATUS = 'CLOSED'
 AND
 WF.Name = 'Sales DE'
 
