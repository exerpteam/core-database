SELECT
    att.ID locker,
    CASE
        WHEN :Gender = 'F'
        THEN 'FEMALE'
        ELSE 'MALE'
    END AS GENDER,
    CASE
            /*FEMALE LOCKERS*/
        WHEN :Gender = 'F'
            AND att.ID <= 27
        THEN 'AREA 1'
        WHEN :Gender = 'F'
            AND att.ID <= 54
        THEN 'AREA 2'
        WHEN :Gender = 'F'
            AND att.ID <= 83
        THEN 'AREA 3'
        WHEN :Gender = 'F'
            AND att.ID <= 143
        THEN 'AREA 4'
        WHEN :Gender = 'F'
            AND att.ID <= 201
        THEN 'AREA 5'
        WHEN :Gender = 'F'
            AND att.ID <= 258
        THEN 'AREA 6'
        WHEN :Gender = 'F'
            AND att.ID <= 296
        THEN 'AREA 7'
        WHEN :Gender = 'F'
            AND att.ID <= 335
        THEN 'AREA 8'
        
            /*MALE LOCKERS*/
        WHEN :Gender = 'M'
            AND att.ID <= 58
        THEN 'AREA 1'
        WHEN :Gender = 'M'
            AND att.ID <= 90
        THEN 'AREA 2'
        WHEN :Gender = 'M'
            AND att.ID <= 125
        THEN 'AREA 3'
        WHEN :Gender = 'M'
            AND att.ID <= 163
        THEN 'AREA 4'
        WHEN :Gender = 'M'
            AND att.ID <= 200
        THEN 'AREA 5'
        WHEN :Gender = 'M'
            AND att.ID <= 240
        THEN 'AREA 6'
        WHEN :Gender = 'M'
            AND att.ID <= 252
        THEN 'AREA 7'
        WHEN :Gender = 'M'
            AND att.ID <= 264
        THEN 'AREA 8'
        WHEN :Gender = 'M'
            AND att.ID <= 276
        THEN 'AREA 9'
        ELSE 'NO AREA'
    END AS GENDER,
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
    (select Rownum id
From dual
Connect By Rownum <= 335) att
LEFT JOIN
    (
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
            TO_CHAR(suadd.START_DATE, 'DD-MM-YYYY') From_Date,
            TO_CHAR(suadd.END_DATE, 'DD-MM-YYYY') To_Date
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
            AND (
                suadd.END_DATE IS NULL
                OR suadd.END_DATE > SYSDATE)
            AND mp.INFO_TEXT = 'L'
			AND p.SEX = :Gender) assigned
ON
	att.ID = assigned.locker_no
WHERE
     (
        att.ID <= 335
        AND :Gender = 'F')
    OR (
        att.ID <= 276
        AND :Gender = 'M')
ORDER BY att.ID