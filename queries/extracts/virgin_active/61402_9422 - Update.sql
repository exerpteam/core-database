-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            c.id
        FROM
            centers c
        WHERE
            c.country = 'IT'
    )
    ,
    timecontrol AS
    (
        SELECT
            CAST(extract(epoch FROM timezone('Europe/Rome', CAST(CURRENT_DATE AS timestamptz))) AS
            bigint)*1000 AS FROMDATE,
            CAST(extract(epoch FROM timezone('Europe/Rome', CAST(CURRENT_DATE AS timestamptz) +
            interval '1 day')) AS BIGINT) * 1000 AS TODATE
    )
SELECT
    p.EXTERNAL_ID "PERSONPHONEID",
    p.EXTERNAL_ID "PERSONID",
    CASE atts.NAME
        WHEN '_eClub_PhoneHome'
        THEN 'HOME'
        WHEN '_eClub_PhoneSMS'
        THEN 'CELLULAR'
        WHEN '_eClub_PhoneWork'
        THEN 'WORK'
        ELSE 'UNDEFINED'
    END           "PHONETYPE",
    atts.TXTVALUE "PHONENUMBER",
    entryTime AS  "LASTSEENDATE"
FROM
    PERSONS p
JOIN
    params par
ON
    par.ID = p.center
JOIN
    PERSON_EXT_ATTRS atts
ON
    p.CENTER = atts.PERSONCENTER
AND p.ID = atts.PERSONID
AND atts.NAME IN ('_eClub_PhoneHome',
                  '_eClub_PhoneSMS',
                  '_eClub_PhoneWork')
AND atts.TXTVALUE IS NOT NULL
LEFT JOIN
    (
        SELECT
            CENTER,
            ID,
            attribute,
            entryTime
        FROM
            (
                SELECT
                    p2.CENTER,
                    p2.ID,
                    (
                        CASE
                            WHEN pcl.CHANGE_ATTRIBUTE='HOME_PHONE'
                            THEN '_eClub_PhoneHome'
                            WHEN pcl.CHANGE_ATTRIBUTE='MOB_PHONE'
                            THEN '_eClub_PhoneSMS'
                            WHEN pcl.CHANGE_ATTRIBUTE='WORK_PHONE'
                            THEN '_eClub_PhoneWork'
                        END)                                    AS attribute,
                    longToDateC(pcl.ENTRY_TIME,100)                                    AS entryTime,
                    row_number() over (partition BY p2.center,p2.id ORDER BY pcl.ENTRY_TIME ASC) AS rn
                FROM
                    timecontrol,
                    PERSONS p2
                JOIN
                    PERSON_CHANGE_LOGS pcl
                ON
                    pcl.PERSON_CENTER = p2.CENTER
                AND pcl.PERSON_ID = p2.ID
                AND pcl.PREVIOUS_ENTRY_ID IS NULL
                AND pcl.CHANGE_ATTRIBUTE IN ('HOME_PHONE',
                                             'MOB_PHONE',
                                             'WORK_PHONE')
                JOIN params par2
                ON par2.id = p2.center
                WHERE
                    p2.STATUS IN (1,3)
                AND p2.SEX != 'C'
                AND pcl.entry_time BETWEEN timecontrol.FROMDATE AND timecontrol.TODATE) subq
        WHERE
            rn = 1 ) t1
ON
    (
        p.CENTER = t1.CENTER
    AND p.ID = t1.ID
    AND atts.NAME = t1.attribute)
WHERE
    p.STATUS IN (1,3)
AND p.SEX != 'C'