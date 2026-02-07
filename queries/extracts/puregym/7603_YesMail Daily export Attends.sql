SELECT DISTINCT
    p2.EXTERNAL_ID                                                                AS "External ID",
    TO_CHAR(longtodatetz(att.START_TIME, 'Europe/London'), 'YYYY-MM-dd HH24:MI') AS "Visit date and time",
    att.CENTER                                                                   AS "Attend Center",
    br.NAME                                                                      AS "Attend Resource Name",
    br.EXTERNAL_ID                                                               AS "Attend Recource external ID"
FROM
    PUREGYM.ATTENDS att
JOIN
    PUREGYM.PERSONS p
ON
    att.PERSON_CENTER = p.CENTER
    AND att.PERSON_ID = p.ID
JOIN
    PUREGYM.PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    email.name='_eClub_Email'
    AND email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
LEFT JOIN
    PUREGYM.BOOKING_RESOURCES br
ON
    br.CENTER = att.BOOKING_RESOURCE_CENTER
    AND br.id = att.BOOKING_RESOURCE_ID
WHERE
    att.START_TIME> dateToLong(TO_CHAR(TRUNC(SYSDATE -3), 'YYYY-MM-dd HH24:MI'))