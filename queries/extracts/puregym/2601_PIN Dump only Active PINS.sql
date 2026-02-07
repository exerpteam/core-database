SELECT
    p.CENTER || 'p' || p.ID            AS PersonID,
    p.firstname                        AS Firstname,
    p.lastname                         AS Lastname,
    TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') AS DOB,
    a4.TXTVALUE                        AS Email,
    e.identity                         AS PIN,
    p.SEX                              AS Gender,
    p.center                           AS BranchId,
    cen.NAME                           AS BranchName,
    secondary_access.TXTVALUE          AS Secondary_BranchID,
    cen2.NAME                          AS Secondary_BranchName,
    maingymoverride.TXTVALUE           AS Maingymoverride_BranchID,
    cen3.NAME                          AS maingymoverride_BranchName,
    MAXEXERP_CI.MaxExerp               AS LastVisit,
    NVL(a1.TXTVALUE, 'false')          AS Sunbed,
    NVL(a2.TXTVALUE, 'false')          AS Disabled,
    NVL(a3.TXTVALUE, 'false')          AS Water,
    CASE
        WHEN p.PERSONTYPE = 2
            AND staff_access.TXTVALUE IN ('ACCESS',
                                          'true')
        THEN 'true'
        ELSE 'false'
    END     AS Staff,
    'false' AS PT,
    CASE
        WHEN p.BLACKLISTED = 0
            AND p.STATUS = 1
        THEN 'Live'
        WHEN p.BLACKLISTED = 2
            AND p.STATUS = 1
        THEN 'Paused'
        WHEN p.PERSONTYPE = 2
            AND staff_access.TXTVALUE IN ('ACCESS',
                                          'true')
        THEN 'Staff'
        ELSE 'Removed'
    END AS Status
FROM
    persons p
    -- PIN
LEFT JOIN
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
    -- Sunbed
LEFT JOIN
    PERSON_EXT_ATTRS a1
ON
    a1.PERSONCENTER = p.CENTER
    AND a1.PERSONID = p.ID
    AND a1.name ='SUNBED_ALLOWED'
    -- Disabled
LEFT JOIN
    PERSON_EXT_ATTRS a2
ON
    a2.PERSONCENTER = p.CENTER
    AND a2.PERSONID = p.ID
    AND a2.name ='DISABLED_ACCESS'
    -- Water
LEFT JOIN
    PERSON_EXT_ATTRS a3
ON
    a3.PERSONCENTER = p.CENTER
    AND a3.PERSONID = p.ID
    AND a3.name ='WATER'
LEFT JOIN
    PERSON_EXT_ATTRS a4
ON
    a4.PERSONCENTER = p.CENTER
    AND a4.PERSONID = p.ID
    AND a4.name ='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS staff_access
ON
    staff_access.PERSONCENTER = p.CENTER
    AND staff_access.PERSONID = p.ID
    AND staff_access.NAME ='STAFF_ACCESS'
LEFT JOIN
    PERSON_EXT_ATTRS secondary_access
ON
    secondary_access.PERSONCENTER = p.CENTER
    AND secondary_access.PERSONID = p.ID
    AND secondary_access.NAME ='SECONDARY_CENTER'
LEFT JOIN
    PERSON_EXT_ATTRS maingymoverride
ON
    maingymoverride.PERSONCENTER = p.CENTER
    AND maingymoverride.PERSONID = p.ID
    AND maingymoverride.NAME ='MAIN_CENTER_OVERRIDE'
LEFT JOIN
    (
        SELECT
            ci.PERSON_CENTER ,
            ci.PERSON_ID ,
            TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS
            MaxExerp
        FROM
            PUREGYM.CHECKINS ci
        GROUP BY
            ci.PERSON_CENTER ,
            ci.PERSON_ID ) MAXEXERP_CI
ON
    MAXEXERP_CI.PERSON_CENTER = p.center
    AND MAXEXERP_CI.PERSON_ID = p.id
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
LEFT JOIN
    PUREGYM.CENTERS cen2
ON
    cen2.ID = secondary_access.TXTVALUE
LEFT JOIN
    PUREGYM.CENTERS cen3
ON
    cen3.ID = maingymoverride.TXTVALUE
    -- Specific center
    -- select * from PUREGYM.PERSON_EXT_ATTRS
WHERE
    e.IDENTITY IS NOT NULL
    AND (
        p.status IN (1)
        OR (
            p.status IN (0,9)
            AND p.PERSONTYPE IN (2)) )
    AND p.BLACKLISTED = 0
    AND (
        EXISTS
        (
            SELECT
                1
            FROM
                PUREGYM.SUBSCRIPTIONS s
            JOIN
                PUREGYM.SUBSCRIPTIONTYPES st
            ON
                s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                AND s.SUBSCRIPTIONTYPE_ID = st.id
                AND st.ST_TYPE in (0,1)
            WHERE
                s.OWNER_CENTER = p.CENTER
                AND s.OWNER_ID = p.id
                AND s.STATE IN (2))
        OR p.PERSONTYPE = 2)