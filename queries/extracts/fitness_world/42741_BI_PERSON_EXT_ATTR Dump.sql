-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    (SELECT
    p.EXTERNAL_ID AS "PERSON_ID",
    pea.NAME      AS "NAME",
    CASE
        WHEN pea.TXTVALUE = 'true'
        THEN 'TRUE'
        WHEN pea.TXTVALUE = 'false'
        THEN 'FALSE'
        ELSE pea.TXTVALUE
    END                AS "VALUE",
    p.CENTER           AS "CENTER_ID",
    pea.LAST_EDIT_TIME AS "ETS"
FROM
    PERSONS p
JOIN
    PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.center
    AND pea.PERSONID =p.id
WHERE
    p.SEX != 'C'
    -- Exclude Transferred
    AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND p.id = p.TRANSFERS_CURRENT_PRS_ID
    AND instr(pea.NAME,'eClub') =0
    AND pea.NAME != 'CREATION_DATE') biview