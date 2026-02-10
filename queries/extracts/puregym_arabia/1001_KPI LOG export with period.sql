-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            c.id,
            datetolongC(TO_CHAR(CAST($$fromdate$$ AS DATE) + 1,'YYYY-MM-DD HH24:MI'),c.id) AS FROMDATE ,
            datetolongC(TO_CHAR(CAST($$todate$$ AS DATE) + 2,'YYYY-MM-DD HH24:MI'),c.id) AS TODATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    (
        SELECT
            kf.EXTERNAL_ID    AS "KPI_FIELD" ,
            kd.CENTER         AS "CENTER_ID" ,
            c.shortname       AS "CENTER_NAME" ,
            kd.FOR_DATE       AS "FOR_DATE" ,
            ROUND(kd.VALUE,0) AS "KPI_VALUE" ,
            CASE
                WHEN kf.TYPE = 'EXTERNAL'
                THEN 'EXTERNAL'
                ELSE 'SYSTEM'
            END          AS "TYPE" ,
            kd.TIMESTAMP AS "ETS"
        FROM
            KPI_DATA kd
        JOIN
            params
        ON
            params.id = kd.CENTER
        JOIN
            centers c
        ON
            c.id = kd.CENTER
        JOIN
            KPI_FIELDS kf
        ON
            kf.id = kd.FIELD
        WHERE
            kf.external_id NOT IN ('NET_GAIN',
                                   'MEMBERS_DAY_BEFORE')
        AND kd.TIMESTAMP BETWEEN params.FROMDATE AND params.TODATE
        AND c.id IN ($$scope$$) )biview