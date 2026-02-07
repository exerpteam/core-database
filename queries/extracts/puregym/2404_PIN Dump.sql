SELECT
    p.firstname               AS Firstname,
    p.lastname                AS Lastname,
    e.identity                AS PIN,
    p.SEX                     AS Gender,
    p.center                  AS BranchId,
    NVL(a1.TXTVALUE, 'false') AS Sunbed,
    NVL(a2.TXTVALUE, 'false') AS Disabled,
    NVL(a3.TXTVALUE, 'false') AS Water,
    'false'                   AS Staff,
    'false'                   AS PT,
    CASE
        WHEN p.BLACKLISTED = 0
            AND p.STATUS = 1
        THEN 'Live'
        WHEN p.BLACKLISTED = 2
            AND p.STATUS = 1
        THEN 'Paused'
        WHEN p.PERSONTYPE = 2
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
WHERE
    e.IDENTITY IS NOT NULL
