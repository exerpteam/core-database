WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            exerpro.datetolong(TO_CHAR(TRUNC(SYSDATE)-5, 'YYYY-MM-DD HH24:MI')) AS FROMDATE,
            exerpro.datetolong(TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD HH24:MI')) AS TODATE
        FROM
            dual
    )
SELECT
    *
FROM
    BI_SUBSCRIPTION_STATE_LOG ssl
CROSS JOIN
    PARAMS
WHERE
    ssl.SUBSCRIPTION_CENTER_ID IN ($$scope$$)
    AND ssl.ETS >= PARAMS.FROMDATE
    AND ssl.ETS < PARAMS.TODATE