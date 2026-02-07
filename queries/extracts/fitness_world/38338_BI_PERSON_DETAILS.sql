-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    p.EXTERNAL_ID   AS "PERSON_ID",
    p.ADDRESS1      AS "ADDRESS1",
    p.ADDRESS2      AS "ADDRESS2",
    p.ADDRESS3      AS "ADDRESS3",
    pea1.TXTVALUE   AS "WORK_PHONE",
    pea2.TXTVALUE   AS "MOBILE_PHONE",
    pea3.TXTVALUE   AS "HOME_PHONE",
    pea4.TXTVALUE   AS "EMAIL",
    p.CENTER        AS "CENTER_ID",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    params,
    PERSONS p
LEFT JOIN
    PERSON_EXT_ATTRS pea1
ON
    pea1.name ='_eClub_PhoneWork'
    AND pea1.PERSONCENTER = p.center
    AND pea1.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.name ='_eClub_PhoneSMS'
    AND pea2.PERSONCENTER = p.center
    AND pea2.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea3
ON
    pea3.name ='_eClub_PhoneHome'
    AND pea3.PERSONCENTER = p.center
    AND pea3.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea4
ON
    pea4.name ='_eClub_Email'
    AND pea4.PERSONCENTER = p.center
    AND pea4.PERSONID =p.id
WHERE
    p.SEX != 'C'
    -- Exclude Transferred
    AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND p.id = p.TRANSFERS_CURRENT_PRS_ID
AND p.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
