-- The extract is extracted from Exerp on 2026-02-08
-- Pulls a list of all active Activity Groups with IDs and names to use in the Activity Audit
SELECT
    id AS activity_group_ID,
    name,
    state,
    longtodateTZ(last_modified, 'America/Toronto') AS "Last_modified_time"
FROM
    activity_group
WHERE
    state = 'ACTIVE'
AND name IS NOT NULL
ORDER BY
    activity_group_ID