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
    BI_SUBSCRIPTION_STATE_LOG biview
WHERE
    biview.ETS >= PARAMS.FROMDATE 
	AND biview."ETS" < PARAMS.TODATE
    AND biview."CENTER_ID" in ($$scope$$)