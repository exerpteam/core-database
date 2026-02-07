-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$,
                    'yyyy-MM-dd HH24:MI')) AS BIGINT)
            END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS
            BIGINT) AS TODATE
    )
SELECT
    kf.EXTERNAL_ID                    AS "KPI_FIELD",
    CAST ( kd.CENTER AS VARCHAR(255)) AS "CENTER_ID",
    kd.FOR_DATE                       AS "FOR_DATE",
    TO_CHAR(kd.VALUE,'9999999999')    AS "KPI_VALUE",
    CASE
        WHEN kf.TYPE= 'EXTERNAL'
        THEN 'EXTERNAL'
        ELSE 'SYSTEM'
    END          AS "TYPE",
    REPLACE(TO_CHAR(kd.TIMESTAMP,'FM999G999G999G999G999'),',','.')     AS "ETS"      
FROM
    params,
    KPI_DATA kd
JOIN
    KPI_FIELDS kf
ON
    kf.id = kd.FIELD
WHERE
    kf.EXTERNAL_ID LIKE 'BI_%'
AND kd.TIMESTAMP BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE