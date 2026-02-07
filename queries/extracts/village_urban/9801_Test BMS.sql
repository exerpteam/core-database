SELECT p.CENTER||'p'|| p.ID AS Person,
       p.EXTERNAL_ID AS EXT_ID,
       p.FIRSTNAME AS FIRST_NAME,
       p.LASTNAME AS LAST_NAME,
       p.BIRTHDATE AS DOB,
       p.SEX AS GENDER,
       c.FACILITY_URL AS FAC_URL,
       c.NAME AS CENTER_NAME
      
       
FROM
        PERSONS p
JOIN
        VU.CENTERS c
ON
        p.CENTER = c.ID
LEFT JOIN
        PERSON_EXT_ATTRS pea
ON
        p.CENTER = pea.PERSONCENTER AND p.ID = pea.PERSONID AND pea.NAME = '_eClub_WellnessCloudUserPermanentToken'
WHERE
        --pea.NAME = '_eClub_WellnessCloudUserPermanentToken'
        p.STATUS IN (1)
        AND pea.TXTVALUE IS NULL
       --  p.CENTER = 131 AND p.ID = 2617

        --AND pea.TXTVALUE IS NULL
                
