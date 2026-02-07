SELECT
        c.name                                           AS "CLUB",
        br.NAME                                          AS "NAME",
        br.STATE                                         AS "STATE",
        br.TYPE                                          AS "TYPE",
        bpg.ID                                           AS "ACCESS_GROUP_ID",
        bpg.NAME                                         AS "ACCESS_GROUP_NAME",
        CAST(CAST (br.SHOW_CALENDAR AS INT) AS SMALLINT) AS "SHOW_CALENDAR",
        br.CENTER                                        AS "CENTER_ID",       
        brc.business_starttimes                          AS "BUSINESS_START_TIME"
FROM
        fernwood.booking_resources br
LEFT JOIN
        fernwood.booking_privilege_groups bpg
        ON bpg.ID = br.ATTEND_PRIVILEGE_ID
LEFT JOIN
        fernwood.booking_resource_configs brc
        ON brc.booking_resource_center = br.center
        AND brc.booking_resource_id = br.id
JOIN
        fernwood.centers c
        ON c.id = br.center 