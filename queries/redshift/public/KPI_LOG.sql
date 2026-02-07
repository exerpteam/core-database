SELECT
    kf.ID          AS "ID",
    kf.EXTERNAL_ID AS "EXTERNAL_ID",
    kd.CENTER      AS "CENTER_ID",
    kd.FOR_DATE    AS "FOR_DATE",
    kd.VALUE       AS "VALUE",
    CASE
        WHEN kf.TYPE= 'EXTERNAL'
        THEN 'EXTERNAL'
        ELSE 'SYSTEM'
    END          AS "TYPE",
    kf.STATE as "STATE",
    kd.TIMESTAMP AS "ETS"
FROM
    KPI_DATA kd
JOIN
    KPI_FIELDS kf
ON
    kf.id = kd.FIELD
