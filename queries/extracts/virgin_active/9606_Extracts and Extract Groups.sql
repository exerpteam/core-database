SELECT
    e.ID as "Extract ID",
    e.NAME as "Extract Name",
    eg.ID as "Group ID",
    eg.NAME as "Extract Group",
    LISTAGG(rolename, '; ') WITHIN GROUP (ORDER BY e.ID, e.NAME , eg.ID , eg.NAME ) AS "Roles in Extract Group"
FROM
    EXTRACT e
JOIN
    EXTRACT_GROUP_LINK egl
ON
    egl.EXTRACT_ID = e.ID
JOIN
    EXTRACT_GROUP eg
ON
    egl.GROUP_ID = eg.ID
JOIN
    EXTRACT_GROUP_AND_ROLE_LINK erl
ON
    erl.EXTRACT_GROUP_ID = eg.id
JOIN
    ROLES ro
ON
    erl.ROLE_ID = RO.id
WHERE
    eg.ID != 1002
GROUP BY
    e.ID,
    e.NAME ,
    eg.ID ,
    eg.NAME
order by e.id