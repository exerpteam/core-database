SELECT
    per.FULLNAME,
    per.center || 'p' || per.id AS "P ref",
    pin.IDENTITY                AS PIN,
    cen.NAME                    AS "Primary Center",
    CASE
        WHEN maxHome.CHECKIN_CENTER = per.center
        THEN maxHome.MaxExerp
        ELSE NULL
    END AS "Primary Last Attendance",
    maxHome.cnt "Primary attendance count",
    seccen.NAME AS "Secondary Gym",
    CASE
        WHEN maxHome2.CHECKIN_CENTER = seccen.ID
        THEN maxHome2.MaxExerp
        ELSE NULL
    END AS "Secondary Last Attendance",
    maxHome2.cnt "secondary attendance count"
FROM
    PUREGYM.PERSONS per
LEFT JOIN PUREGYM.CENTERS cen
ON
    cen.ID = per.CENTER
LEFT JOIN PUREGYM.ENTITYIDENTIFIERS pin
ON
    pin.REF_CENTER = per.CENTER
    AND pin.REF_ID = per.ID
    AND pin.IDMETHOD = 5
    AND pin.ENTITYSTATUS = 1
    AND pin.REF_TYPE = 1
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS ext
ON
    ext.PERSONCENTER = per.CENTER
    AND ext.PERSONID = per.ID
    AND ext.NAME = 'SECONDARY_CENTER'
LEFT JOIN PUREGYM.CENTERS seccen
ON
    seccen.ID = ext.TXTVALUE
LEFT JOIN
    (
        SELECT
            p.center,
            p.id,
            ci.CHECKIN_CENTER,
			COUNT( distinct CEIL(ci.CHECKIN_TIME/1000/60/60/24)) cnt,
            TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
        FROM
            PUREGYM.PERSONS p
        JOIN PUREGYM.CHECKINS ci
        ON
            ci.PERSON_CENTER = p.center
            AND ci.PERSON_ID = p.id
        WHERE
            ci.CHECKIN_TIME > :checkinTimeStart
        GROUP BY
            p.center,
            p.id,
            ci.CHECKIN_CENTER
    )
    maxHome
ON
    maxHome.center = per.center
    AND maxHome.id = per.id
    AND maxHome.CHECKIN_CENTER IN (per.center)
LEFT JOIN
    (
        SELECT
            p.center,
            p.id,
            ci.CHECKIN_CENTER,
            COUNT( distinct CEIL(ci.CHECKIN_TIME/1000/60/60/24)) cnt,
            TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
        FROM
            PUREGYM.PERSONS p
        JOIN PUREGYM.CHECKINS ci
        ON
            ci.PERSON_CENTER = p.center
            AND ci.PERSON_ID = p.id
        WHERE
            ci.CHECKIN_TIME > :checkinTimeStart
        GROUP BY
            p.center,
            p.id,
            ci.CHECKIN_CENTER
    )
    maxHome2
ON
    maxHome2.center = per.center
    AND maxHome2.id = per.id
    AND maxHome2.CHECKIN_CENTER IN (seccen.ID)
WHERE
    per.center IN (:center)
    AND per.STATUS IN (1,3)