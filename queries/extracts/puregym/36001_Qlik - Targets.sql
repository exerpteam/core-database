WITH
    params AS
    (
        SELECT
            /*+ materialize */
            DECODE($$offset$$,0,to_date('1970-01-01','yyyy-MM-dd'),TRUNC(SYSDATE-$$offset$$)) AS from_date,
            TRUNC(SYSDATE-1)                                                                  AS to_date
        FROM
            dual
    )
SELECT
    kf.EXTERNAL_ID AS TARGET_FIELD,
    kd.CENTER      AS CENTER_ID,
    kd.FOR_DATE,
    TO_CHAR(kd.VALUE) AS TARGET
FROM
    params,
    KPI_DATA kd
JOIN
    KPI_FIELDS kf
ON
    kf.id = kd.FIELD
WHERE
    kf.EXTERNAL_ID LIKE 'BI_%'
    AND (
        kd.FOR_DATE BETWEEN params.from_date AND params.to_date)
    AND kd.CENTER IN ($$scope$$)
UNION ALL
SELECT
    NULL AS TARGET_FIELD,
    NULL AS CENTER_ID,
    NULL AS FOR_DATE,
    NULL AS TARGET
FROM
    dual