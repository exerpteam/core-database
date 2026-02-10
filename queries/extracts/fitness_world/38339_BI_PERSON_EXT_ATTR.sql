-- The extract is extracted from Exerp on 2026-02-08
--  

WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
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
    REPLACE(TO_CHAR(pea.LAST_EDIT_TIME,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    PARAMS,
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
    AND POSITION('eClub' IN pea.NAME) = 0
    AND pea.NAME != 'CREATION_DATE'
    AND pea.LAST_EDIT_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

