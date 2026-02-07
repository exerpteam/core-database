SELECT
    tt.ID                         AS "ID",
    tt.STATUS                     AS "STATUS",
    wf.EXTERNAL_ID                AS "WORKFLOW",
    tt.NAME                       AS "NAME",
    tt.EXTERNAL_ID                AS "EXTERNAL_ID",
    tt.DESCRIPTION                AS "DESCRIPTION",
    tt.SCOPE_TYPE                 AS "SCOPE_TYPE",
    tt.SCOPE_ID                   AS "SCOPE_ID",
    tt.TASK_CENTER_SELECTION_TYPE AS "TASK_CENTER_SELECTION_TYPE",
    tt.roles                      AS "ROLES",
    tt.manager_roles              AS "MANAGER_ROLES",
    tt.unassigned_roles           AS "UNASSIGNED_ROLES"
FROM
    TASK_TYPES tt
LEFT JOIN
    WORKFLOWS wf
ON
    wf.ID = tt.WORKFLOW_ID