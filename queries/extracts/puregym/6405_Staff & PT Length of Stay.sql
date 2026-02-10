-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.NAME AS "Center Name",
p.center||'p'||p.id as "Person ID", 
    p.FIRSTNAME,
    p.LASTNAME,
    sg.NAME                                                                   AS "Staff Group",
    e.IDENTITY                                                                AS "PIN",
    a.NAME                                                                    AS "Regional Manager",
    email.TXTVALUE                                                            AS "Email",
    mobile.TXTVALUE                                                           AS "Mobile Telephone",
    staff_start.TXTVALUE                                                      AS "Staff Start Date",
    TRUNC(SYSDATE) - to_date(staff_start.TXTVALUE,'yyyy=mm-dd')               AS "Days since Staff start date",
    ROUND((TRUNC(SYSDATE) - to_date(staff_start.TXTVALUE,'yyyy=mm-dd'))/30,2) AS "Months since Staff start date"
FROM
    persons p
JOIN
    PUREGYM.PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER=p.CENTER
    AND psg.PERSON_ID = p.id
JOIN
    PUREGYM.STAFF_GROUPS sg
ON
    sg.ID = psg.STAFF_GROUP_ID
JOIN
    PUREGYM.CENTERS c
ON
    p.CENTER = c.id
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
JOIN
    AREA_CENTERS AC
ON
    C.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    email.personcenter = p.center
    AND email.personid = p.id
    AND email.name = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
ON
    mobile.personcenter = p.center
    AND mobile.personid = p.id
    AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS staff_start
ON
    staff_start.personcenter = p.center
    AND staff_start.personid = p.id
    AND staff_start.name = 'STAFF_STARTDATE'
    where p.STATUS in (0,1,3,9) and p.CENTER in (:scope)