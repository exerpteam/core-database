-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
    pex.TXTVALUE,
    p.FULLNAME                                         person_name,
    p.center || 'p' || p.id                            person_id,
    CASE p.SEX
       WHEN 'M' THEN 'MALE'
       WHEN 'F' THEN 'FEMALE'
       ELSE 'ERROR'
    END gender,
    mp.CACHED_PRODUCTNAME                              add_on_name,
    CASE
        WHEN suadd.ID IS NULL
        THEN 'NONE'
        WHEN suadd.END_DATE IS NOT NULL
            AND suadd.END_DATE < current_date
        THEN 'ENDED'
        ELSE 'ACTIVE'
    END                                     addon_status,
    TO_CHAR(suadd.START_DATE, 'YYYY-MM-DD') from_date,
    TO_CHAR(suadd.END_DATE, 'YYYY-MM-DD')   to_date
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
    pex.TXTVALUE IS NOT NULL
    AND (
        pex.TXTVALUE ~ '[^0-9]'
        OR (
            pex.TXTVALUE ~ '[0-9]([0-9])[0-9]([0-9])' )
        OR (
            pex.TXTVALUE ~ '[0-9]([0-9])[0-9]([:space:])' )
        )
and p.center = :Center 