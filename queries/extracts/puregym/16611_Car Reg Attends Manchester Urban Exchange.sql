WITH
    params AS
    (
        SELECT
            dateToLongtz(TO_CHAR(TRUNC(SYSDATE-1), 'YYYY-MM-dd HH24:MI'),'Europe/London') AS fromtime
        FROM
            dual
    )
SELECT
    pea.TXTVALUE                                                                                                                       AS CarReg,
    TO_CHAR(longtodatetz(MIN(DECODE(br.EXTERNAL_ID,137,att.START_TIME,138,att.START_TIME,436,att.START_TIME,438,att.START_TIME,NULL)),'Europe/London'),'dd-MM-yyyy HH24:MI') AS "Attend date/time In",
    TO_CHAR(longtodatetz(MAX(DECODE(br.EXTERNAL_ID,136,att.START_TIME,143,att.START_TIME,435,att.START_TIME,437,att.START_TIME,NULL)),'Europe/London'),'dd-MM-yyyy HH24:MI') AS "Attend date/time Out",
    att.PERSON_CENTER||'p'||att.PERSON_ID                                                                                              AS MemberID,
    c.NAME                                                                                                                             AS "Attendance Center name"
    /*br.NAME,
    longtodatetz(att.START_TIME,'Europe/London')*/
FROM
    params,
    PUREGYM.ATTENDS att
JOIN
    PUREGYM.BOOKING_RESOURCES br
ON
    br.CENTER = att.BOOKING_RESOURCE_CENTER
    AND br.id = att.BOOKING_RESOURCE_ID
    --AND br.ATTEND_PRIVILEGE_ID = 1
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = att.PERSON_CENTER
    AND pea.PERSONID = att.PERSON_ID
    AND pea.NAME = 'carreg'
JOIN
    PUREGYM.CENTERS c
ON
    c.id = att.CENTER
WHERE
--    att.START_TIME BETWEEN params.fromtime AND params.fromtime +1000*60*60*24 
    att.START_TIME BETWEEN params.fromtime AND dateToLongtz(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-dd HH24:MI'),'Europe/London') 
    AND att.CENTER = 20
GROUP BY
    att.PERSON_CENTER,
    att.PERSON_ID,
    pea.TXTVALUE,
    c.NAME