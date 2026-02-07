SELECT
    DECODE(p.SEX, 'M', 'MALE', 'F', 'FEMALE', 'ERROR') gender,
    pex.TXTVALUE locker_no,
    p.center || 'p' || p.id person_id,
    CASE
        WHEN suadd.ID IS NULL
        THEN 'NO_ADD_ON'
        WHEN suadd.END_DATE IS NOT NULL
            AND suadd.END_DATE < SYSDATE
        THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END status,
    p.FULLNAME person_name,
    mp.CACHED_PRODUCTNAME add_on_name,
    TO_CHAR(suadd.START_DATE, 'YYYY-MM-DD') From_Date,
    TO_CHAR(suadd.END_DATE, 'YYYY-MM-DD') To_Date
FROM
    persons p
JOIN HP.PERSON_EXT_ATTRS pex
ON
    p.CENTER = pex.PERSONCENTER
    AND p.ID = pex.PERSONID
    AND pex.NAME = 'LOCKER_NUMBER'
LEFT JOIN HP.SUBSCRIPTIONS su
ON
    p.CENTER = su.OWNER_CENTER
    AND p.id = su.OWNER_ID
LEFT JOIN HP.SUBSCRIPTION_ADDON suadd
ON
    suadd.SUBSCRIPTION_CENTER = su.CENTER
    AND suadd.SUBSCRIPTION_ID = su.ID
LEFT JOIN HP.MASTERPRODUCTREGISTER mp
ON
    mp.ID = suadd.ADDON_PRODUCT_ID
    AND mp.GLOBALID IN ('PLO_A','PLO_A_24M','PLO_M')
WHERE p.CENTER = :Center