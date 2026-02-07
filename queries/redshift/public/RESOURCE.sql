SELECT
    br.CENTER||'br'||br.ID                           AS "ID",
    br.NAME                                          AS "NAME",
    br.STATE                                         AS "STATE",
    br.TYPE                                          AS "TYPE",
    bpg.ID                                           AS "ACCESS_GROUP_ID",
    bpg.NAME                                         AS "ACCESS_GROUP_NAME",
    br.EXTERNAL_ID                                   AS "EXTERNAL_ID",
    br.COMENT                                        AS "COMMENT",
    CAST(CAST (br.SHOW_CALENDAR AS INT) AS SMALLINT) AS "SHOW_CALENDAR",
    br.CENTER                                        AS "CENTER_ID",
    br.LAST_MODIFIED                                 AS "ETS"
FROM
    BOOKING_RESOURCES br
LEFT JOIN
    BOOKING_PRIVILEGE_GROUPS bpg
ON
    bpg.ID = br.ATTEND_PRIVILEGE_ID
