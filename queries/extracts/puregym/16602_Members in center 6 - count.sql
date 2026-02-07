SELECT /*+ NO_BIND_AWARE */
    'Glasgow Bath Street'                                                                                                                                 AS PERSON_CENTER,
    count(*) as "member count"
FROM
    PUREGYM.ATTENDS att
JOIN
    persons p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID
WHERE
    att.CENTER = 6
    AND att.BOOKING_RESOURCE_ID IN(7,14)--checkins
    AND att.START_TIME > dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')) - 1000*60*60*8
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.ATTENDS att2
        WHERE
            att2.CENTER = 6
            AND att2.BOOKING_RESOURCE_ID IN(8,15) --checkouts
            AND att2.PERSON_CENTER = att.PERSON_CENTER
            AND att2.PERSON_ID = att.PERSON_ID
            AND att.START_TIME<att2.START_TIME)