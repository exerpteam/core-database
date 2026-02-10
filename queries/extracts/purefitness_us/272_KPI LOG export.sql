-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CAST((extract(epoch FROM CURRENT_DATE - $$offset$$)) AS bigint)*1000 AS FROMDATE ,
            CAST((extract(epoch FROM CURRENT_DATE + 1)) AS bigint)*1000          AS TODATE
    )
SELECT
            kf.EXTERNAL_ID                 AS "KPI_FIELD" ,
            kd.CENTER                      AS "CENTER_ID" ,
            c.shortname                    AS "CENTER_NAME" ,
            kd.FOR_DATE                    AS "FOR_DATE" ,
            ROUND(kd.VALUE,0) AS "KPI_VALUE" ,
            CASE
                WHEN kf.TYPE = 'EXTERNAL'
                THEN 'EXTERNAL'
                ELSE 'SYSTEM'
            END          AS "TYPE" ,
            kd.TIMESTAMP AS "ETS"
        FROM
            params,
            KPI_DATA kd
        JOIN
            centers c
        ON
            c.id = kd.CENTER
        JOIN
            AREA_CENTERS AC
        ON
            C.ID = AC.CENTER
        JOIN
            AREAS A
        ON
            A.ID = AC.AREA
           -- Area US
            AND A.PARENT in (7,8,9,10,78)	
        JOIN
            KPI_FIELDS kf
        ON
            kf.id = kd.FIELD
WHERE
    (kf.EXTERNAL_ID LIKE 'BI_%' OR kf.EXTERNAL_ID = 'FROZEN')
    AND kd.TIMESTAMP BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE