 SELECT
     ps.ID                                                  AS "ID",
     ps.NAME                                                AS "NAME",
     ps.DESCRIPTION                                         AS "DESCRIPTION",
     ps.PRIVILEGE_SET_GROUPS_ID                             AS "PRIVILEGE_SET_GROUP_ID",
     psg.NAME                                               AS "PRIVILEGE_SET_GROUP_NAME",
     CASE
        WHEN ps.SCOPE_TYPE = 'C'
        THEN 'CENTER'
        WHEN ps.SCOPE_TYPE = 'A'
        THEN 'AREA'
        WHEN ps.SCOPE_TYPE = 'T'
        THEN 'GLOBAL'
    END                                                     AS "SCOPE_TYPE",
    ps.SCOPE_ID                                             AS "SCOPE_ID"
 FROM
     PRIVILEGE_SETS ps
 LEFT JOIN
     PRIVILEGE_SET_GROUPS psg
 ON
     ps.PRIVILEGE_SET_GROUPS_ID = psg.ID
