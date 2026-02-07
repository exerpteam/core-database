WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id,
            datetolongtz(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI'), c.time_zone) AS FROMDATE,
            datetolongtz(TO_CHAR(TRUNC(SYSDATE+1), 'YYYY-MM-DD HH24:MI'), c.time_zone) AS TODATE
        FROM
            centers c
        WHERE
            id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    BI_SUBSCRIPTION_SALES_LOG biview
JOIN
    PARAMS
ON
    params.id = biview.SUBSCRIPTION_CENTER
WHERE
    biview.ETS >= PARAMS.FROMDATE
AND biview.ETS < PARAMS.TODATE
   