SELECT
    brc.booking_resource_center||'br'||brc.booking_resource_id AS "RESOURCE_ID",
    brc.GROUP_ID                                               AS "RESOURCE_GROUP_ID",
    CASE
        WHEN mytype::text IN ('BUSINESS',
                              'HOLIDAY')
        THEN 'BUSINESS'
        WHEN mytype::text IN ('DAILY')
        THEN 'DAILY'
        ELSE 'WEEKLY'
    END                                   AS "AVAILABILITY_TYPE",
    CAST((xpath('name(/*)', xml_element))[1] AS VARCHAR(255))    AS "VALUE",
    CAST((xpath('.//*/@FROM', xml_element))[1] AS VARCHAR(255))  AS "FROM_TIME",
    CAST((xpath('.//*/@TO',xml_element))[1] AS VARCHAR(255))    AS "TO_TIME",
    brc.LAST_MODIFIED   AS "ETS"
FROM
    (
        SELECT
            'DAILY' mytype,
            x.booking_resource_center,
            x.booking_resource_id,
            x.group_id,
            unnest(xpath('/DAILY',xmlparse(document convert_from(x.AVAILABILITY, 'UTF-8')))) AS xml_element,
            x.LAST_MODIFIED
        FROM
            BOOKING_RESOURCE_CONFIGS x
        UNION ALL
        SELECT
            'WEEKLY' mytype,
            x.booking_resource_center,
            x.booking_resource_id,
            x.group_id,
            unnest(xpath('/WEEKLY/*',xmlparse(document convert_from(x.AVAILABILITY, 'UTF-8')))) AS xml_element,
            x.LAST_MODIFIED
        FROM
            BOOKING_RESOURCE_CONFIGS x
        UNION ALL
        SELECT
            'BUSINESS' mytype,
            x.booking_resource_center,
            x.booking_resource_id,
            x.group_id,
            unnest(xpath('/BUSINESS/*',xmlparse(document convert_from(x.AVAILABILITY, 'UTF-8')))) AS xml_element,
            x.LAST_MODIFIED
        FROM
            BOOKING_RESOURCE_CONFIGS x ) brc