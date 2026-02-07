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