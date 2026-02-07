SELECT
    p.EXTERNAL_ID AS "COMPANY_ID",
    pea.NAME      AS "NAME",
    CASE
        WHEN pea.mimetype = 'text/plain'
        THEN encode(pea.mimevalue,'escape')
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
    p.SEX = 'C'
    -- Exclude Transferred
    AND p.external_id IS NOT NULL
    AND pea.NAME NOT LIKE '%eClub%'
    AND pea.NAME != 'CREATION_DATE'
    