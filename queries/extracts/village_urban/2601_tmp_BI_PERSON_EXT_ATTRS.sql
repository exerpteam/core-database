-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
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
    AND p.STATUS NOT IN (4)
    AND instr(pea.NAME,'_eClub_') =0
    AND pea.NAME != 'CREATION_DATE')	 biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE