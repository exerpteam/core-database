SELECT
    p.EXTERNAL_ID      AS "PERSON_ID",
    pea.NAME           AS "NAME",
    CASE
        WHEN pea.name in ('_eClub_PictureFace','_eClub_Picture') AND pea.mimevalue is not null THEN 'True'
        WHEN pea.name in ('_eClub_PictureFace','_eClub_Picture') AND pea.mimevalue is null THEN 'False'
        WHEN pea.mimetype = 'text/plain' THEN encode(pea.mimevalue,'escape')
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
    AND p.external_id IS NOT NULL
