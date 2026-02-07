SELECT DISTINCT
    act.NAME as "ACTIVITY NAME",
    sg.NAME as "STAFF GROUP"
FROM
    activity act
JOIN
    activity_staff_configurations ac
ON
    ac.ACTIVITY_ID = act.id
JOIN
    staff_groups sg
ON
    sg.id = ac.STAFF_GROUP_ID
WHERE
    act.TOP_NODE_ID IS NULL