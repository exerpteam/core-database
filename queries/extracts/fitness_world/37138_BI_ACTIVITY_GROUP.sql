-- This is the version from 2026-02-05
--  
SELECT
    CAST ( ag.ID AS VARCHAR(255)) AS "ACTIVITY_GROUP_ID",
    ag.NAME                       AS "NAME",
    ag.STATE                      AS "STATE"
FROM
    ACTIVITY_GROUP ag
WHERE
    ag.TOP_NODE_ID IS NULL
AND ag.STATE != 'DRAFT'