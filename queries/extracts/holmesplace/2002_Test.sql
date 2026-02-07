SELECT
    pex.TXTVALUE locker_no,
    p.FULLNAME person_name,
    p.center || 'p' || p.id person_id,
    DECODE(p.SEX, 'M', 'MALE', 'F', 'FEMALE', 'ERROR') gender,
    mp.CACHED_PRODUCTNAME add_on_name,
    CASE
        WHEN suadd.ID IS NULL
        THEN 'NONE'
        WHEN suadd.END_DATE IS NOT NULL
            AND suadd.END_DATE < SYSDATE
        THEN 'ENDED'
        ELSE 'ACTIVE'
    END addon_status,
    TO_CHAR(suadd.START_DATE, 'YYYY-MM-DD') From_Date,
    TO_CHAR(suadd.END_DATE, 'YYYY-MM-DD') To_Date
FROM
    persons p
JOIN
    PERSON_EXT_ATTRS pex
ON
    p.CENTER = pex.PERSONCENTER
    AND p.ID = pex.PERSONID
    AND pex.NAME = 'LOCKER_NUMBER'
LEFT JOIN
    SUBSCRIPTIONS su
ON
    p.CENTER = su.OWNER_CENTER
    AND p.id = su.OWNER_ID
LEFT JOIN
    SUBSCRIPTION_ADDON suadd
ON
    suadd.SUBSCRIPTION_CENTER = su.CENTER
    AND suadd.SUBSCRIPTION_ID = su.ID
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    mp.ID = suadd.ADDON_PRODUCT_ID
WHERE
    p.CENTER = :Center
    AND mp.INFO_TEXT = 'L'