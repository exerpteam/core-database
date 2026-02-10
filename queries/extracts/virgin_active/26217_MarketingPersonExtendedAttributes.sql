-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                CASE
                        WHEN $$offset$$ = -1 THEN 0
                        ELSE datetolongC(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$,'yyyy-MM-dd HH24:MI'),c.id)
                END AS FROMDATE,
                datetolongC(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI'),c.id) AS TODATE,
                c.id
        FROM
                centers c
        WHERE
                c.country = 'GB'
    )
SELECT
    p.EXTERNAL_ID      AS "PERSON_ID",
    pea.NAME           AS "NAME",
    CASE
        WHEN pea.mimetype = 'text/plain'
        THEN encode(pea.mimevalue,'escape')
        ELSE pea.TXTVALUE
    END                AS "VALUE",
    p.CENTER           AS "CENTER_ID",
    pea.LAST_EDIT_TIME AS "ETS"
FROM PERSONS p
JOIN params ON p.center = params.id    
JOIN PERSON_EXT_ATTRS pea
        ON pea.PERSONCENTER = p.center AND pea.PERSONID =p.id
WHERE
        p.SEX != 'C'
        -- Exclude Transferred
        AND p.status NOT IN (4)
        AND pea.NAME NOT LIKE '%eClub%'
        AND pea.NAME != 'CREATION_DATE'
        AND pea.LAST_EDIT_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
        AND  p.CENTER IN ($$scope$$)