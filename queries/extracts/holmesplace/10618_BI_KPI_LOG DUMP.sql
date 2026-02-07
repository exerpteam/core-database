SELECT
    kf.EXTERNAL_ID                 AS "KPI_FIELD",
    kd.CENTER                      AS "CENTER_ID",
    kd.FOR_DATE                    AS "FOR_DATE",
    TO_CHAR(kd.VALUE,'9999999999') AS "KPI_VALUE",
    CASE
        WHEN kf.TYPE= 'EXTERNAL'
        THEN 'EXTERNAL'
        ELSE 'SYSTEM'
    END          AS "TYPE",
    kd.TIMESTAMP AS "ETS"
FROM
    KPI_DATA kd
JOIN
    KPI_FIELDS kf
ON
    kf.id = kd.FIELD
WHERE
    kf.EXTERNAL_ID LIKE 'BI_%'