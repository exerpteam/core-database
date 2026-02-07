

SELECT
    att.ID locker,
    CASE
        WHEN assigned.locker_no IS NULL
        THEN 'FREE'
        WHEN assigned.addon_status <> 'ACTIVE'
        THEN 'ENDED'
        ELSE 'ASSIGNED'
    END AS LOCKER_STAT,
    assigned.person_name,
    assigned.person_id,
    gender,
    add_on_name,
    addon_status,
    from_date,
    to_date
FROM
    (
        SELECT
            generate_series(1, 1000) id) att
LEFT JOIN
    (
        SELECT
            p.CENTER,
            pex.TXTVALUE            locker_no,
            p.FULLNAME              person_name,
            p.center || 'p' || p.id person_id,
            CASE p.SEX
                WHEN 'M'
                THEN 'MALE'
                WHEN 'F'
                THEN 'FEMALE'
                ELSE 'ERROR'
            END                   AS GENDER,
            mp.CACHED_PRODUCTNAME    add_on_name,
            CASE
                WHEN suadd.ID IS NULL
                THEN 'NONE'
                WHEN suadd.END_DATE IS NOT NULL
                    AND suadd.END_DATE < CURRENT_DATE
                THEN 'ENDED'
                ELSE 'ACTIVE'
            END                                     addon_status,
            TO_CHAR(suadd.START_DATE, 'YYYY-MM-DD') From_Date,
            TO_CHAR(suadd.END_DATE, 'YYYY-MM-DD')   To_Date
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
            p.CENTER = $$Center$$
            AND (
                suadd.END_DATE IS NULL
                OR suadd.END_DATE > CURRENT_DATE)
            AND mp.INFO_TEXT = 'L'
        ORDER BY
            suadd.START_DATE DESC ) assigned
ON
    cast(att.ID as text) = assigned.locker_no
WHERE
    att.ID >=
    (
        SELECT
            CAST(REGEXP_REPLACE(bkr.EXTERNAL_ID, ' *([0-9]+)[-]([0-9]+)','\1') AS INTEGER)
        FROM
            booking_resources bkr
        WHERE
            bkr.CENTER = $$Center$$
            AND ((
                    $$Gender$$ = 'F'
                    AND bkr.COMENT = 'FEMALE_LOCKERS')
                OR (
                    $$Gender$$ = 'M'
                    AND bkr.COMENT = 'MALE_LOCKERS') ))
    AND att.ID <=
    (
        SELECT
            CAST(REGEXP_REPLACE(bkr.EXTERNAL_ID, ' *([0-9]+)[-]([0-9]+)','\2') AS INTEGER)
        FROM
            booking_resources bkr
        WHERE
            bkr.CENTER = $$Center$$
            AND ((
                    $$Gender$$ = 'F'
                    AND bkr.COMENT = 'FEMALE_LOCKERS')
                OR (
                    $$Gender$$ = 'M'
                    AND bkr.COMENT = 'MALE_LOCKERS') ) )
ORDER BY
    att.ID

