-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT /*+ NO_BIND_AWARE */
    'London Hammersmith Palais'                                                                                                                                 AS PERSON_CENTER,
    count(*) as "member count"
FROM
    PUREGYM.ATTENDS att
JOIN
    persons p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID
WHERE
    att.CENTER = 95
    AND att.BOOKING_RESOURCE_ID IN(5,401)--checkins
    AND att.START_TIME > dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')) - 1000*60*60*8
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.ATTENDS att2
        WHERE
            att2.CENTER = 95
            AND att2.BOOKING_RESOURCE_ID IN(6,601) --checkouts
            AND att2.PERSON_CENTER = att.PERSON_CENTER
            AND att2.PERSON_ID = att.PERSON_ID
            AND att.START_TIME<att2.START_TIME)