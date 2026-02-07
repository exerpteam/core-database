SELECT DISTINCT
    t.PERSON_CENTER || 'p' || t.PERSON_ID "Mem ID"
  , longToDateC(t.CREATION_TIME,t.PERSON_CENTER) "Created Date"
  ,tsf.NAME "Start Task Step"
  ,MAX(PEmp.FULLNAME ) over (partition BY i1.task_id, i1.actual_step) "Assigned to"
  ,MAX(ta.NAME ) over (partition BY i1.task_id, i1.actual_step) "Task action"
    --,ta.NAME
  , MAX(
        CASE
            WHEN tld.NAME = 'RequirementType.USER_CHOICE'
                AND tld.VALUE IS NOT NULL
            THEN tld.VALUE
            ELSE NULL
        END) over (partition BY i1.task_id, i1.actual_step) "User choice"
  , ts.NAME "New Task Step"
  ,longToDateC(i1.MIN_ENTRY_TIME,t.PERSON_CENTER) "New Task step Date"
  ,first_value(tl.TASK_STATUS) over (partition BY i1.task_id, i1.actual_step ORDER BY tld.ID DESC nulls last) "Task status"
  ,t.STATUS
  ,CASE
        WHEN t.STATUS = 'CLOSED'
        THEN TO_CHAR(longToDateC(t.LAST_UPDATE_TIME,t.PERSON_CENTER),'YYYY-MM-DD')
        ELSE NULL
    END "Close Date"
FROM
    (
        SELECT
            TASK_ID
          ,MIN(MIN_ENTRY_TIME) MIN_ENTRY_TIME
          ,MAX(MAX_ENTRY_TIME) MAX_ENTRY_TIME
          , ACTUAL_STEP
        FROM
            (
                SELECT
                    TASK_ID
                  ,MIN_ENTRY_TIME
                  ,MAX_ENTRY_TIME
                  , lead(TASK_STEP_ID,1,CURRENT_STEP_ID) over (partition BY TASK_ID ORDER BY MIN_ENTRY_TIME ASC) ACTUAL_STEP
                FROM
                    (
                        SELECT
                            tl.TASK_STEP_ID
                          ,t.STEP_ID CURRENT_STEP_ID
                          ,tl.TASK_ID
                          , MIN(tl.ENTRY_TIME) MIN_ENTRY_TIME
                          , MAX(tl.ENTRY_TIME) MAX_ENTRY_TIME
                        FROM
                            TASK_LOG tl
                        JOIN
                            TASKS t
                        ON
                            t.id = tl.TASK_ID
                        JOIN
                            TASK_TYPES tt
                        ON
                            tt.id = t.TYPE_ID
                        JOIN
                            WORKFLOWS wf
                        ON
                            wf.ID = tt.WORKFLOW_ID
                        WHERE
                            t.CREATION_TIME BETWEEN $$created_from$$ AND $$created_to$$
                            AND UPPER(wf.NAME) = UPPER($$workflow_name$$)
                            AND t.PERSON_CENTER IN ($$scope$$)
                        GROUP BY
                            tl.TASK_STEP_ID
                          ,tl.TASK_ID
                          ,t.STEP_ID
                        ORDER BY
                            MIN(tl.ENTRY_TIME) ASC ) )
        GROUP BY
            TASK_ID
          , ACTUAL_STEP
        ORDER BY
            3 ASC ) i1
JOIN
    TASKS t
ON
    t.ID = i1.TASK_ID
JOIN
    TASK_TYPES tt
ON
    tt.ID = t.TYPE_ID
JOIN
    WORKFLOWS wf
ON
    wf.ID = tt.WORKFLOW_ID
JOIN
    TASK_STEPS tsf
ON
    tsf.id = wf.INITIAL_STEP_ID
JOIN
    TASK_STEPS ts
ON
    ts.id = i1.actual_step
LEFT JOIN
    TASK_LOG tl
ON
    tl.TASK_ID = i1.task_id
    AND tl.ENTRY_TIME >= i1.MIN_ENTRY_TIME
    AND tl.ENTRY_TIME <= i1.MAX_ENTRY_TIME
LEFT JOIN
    PERSONS PEmp
ON
    (
        tl.EMPLOYEE_CENTER IS NOT NULL
        AND tl.EMPLOYEE_CENTER = PEmp.CENTER
        AND tl.EMPLOYEE_ID = PEmp.ID
        )
        
    OR (
        tl.EMPLOYEE_CENTER IS NULL and PEmp.CENTER = t.ASIGNEE_CENTER
        AND PEmp.ID = t.ASIGNEE_ID)
        
LEFT JOIN
    TASK_ACTIONS ta
ON
    ta.ID = tl.TASK_ACTION_ID
LEFT JOIN
    TASK_LOG_DETAILS tld
ON
    tld.TASK_LOG_ID = tl.id
    AND tld.TYPE = 'ATTRIBUTE_CHANGED'
    AND tld.NAME IN ('RequirementType.USER_CHOICE'
                   ,'_eClub_ASSIGNED_TO'
                   ,'_eClub_PERMANENT_NOTE')
LEFT JOIN
    PERSONS pass
ON
    pass.CENTER || 'p' || pass.ID = tld.VALUE
    AND tld.NAME = '_eClub_ASSIGNED_TO'
ORDER BY
    longToDateC(i1.MIN_ENTRY_TIME,t.PERSON_CENTER) ASC