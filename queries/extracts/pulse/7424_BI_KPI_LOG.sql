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
    BI_KPI_LOG biview
WHERE
    biview.ETS > PARAMS.FROMDATE
union all
SELECT
    NULL AS "KPI_FIELD",
    NULL AS "CENTER_ID",
    NULL AS "FOR_DATE",
    NULL AS "KPI_VALUE",
    NULL AS "TYPE",
    NULL AS "ETS"
FROM
    dual