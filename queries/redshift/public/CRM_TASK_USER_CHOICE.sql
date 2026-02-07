SELECT
    tuc.ID            AS "ID",
    tuc.STATUS        AS "STATUS",
    wf.EXTERNAL_ID    AS "WORKFLOW",
    tuc.NAME          AS "NAME",
    tuc.DESCRIPTION   AS "DESCRIPTION",
    tuc.REQUIRES_TEXT AS "REQUIRES_TEXT"
FROM
    TASK_USER_CHOICES tuc
LEFT JOIN
    WORKFLOWS wf
ON
    wf.ID = tuc.WORKFLOW_ID