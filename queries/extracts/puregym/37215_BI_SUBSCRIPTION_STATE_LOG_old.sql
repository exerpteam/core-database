WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-4,0,-3,0,-1,0,-2,$$offset_from$$,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            DECODE($$offset$$,-4,0,-3,$$offset_to$$,-2,$$offset_to$$, (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000)  AS TODATE   
        FROM
            dual
)
SELECT
    distinct biview.*
FROM
(
SELECT
    CAST ( fromstate.KEY AS VARCHAR(255))                                                       AS "SUB_STATE_CHANGE_ID",
    CAST ( sub.CENTER AS VARCHAR(255))                                                          AS "SUBSCRIPTION_CENTER_ID",
    sub.CENTER || 'ss' || sub.ID                                                                AS "SUSBCRIPTION_ID",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','STATE',fromstate.STATEID)                                 AS "STATE",
    BI_DECODE_FIELD ('SUBSCRIPTIONS','SUB_STATE',fromstate.SUB_STATE)                           AS "SUB_STATE",
    TO_CHAR(longtodateC(fromstate.ENTRY_START_TIME, fromstate.CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "ENTRY_START_TIME",
    TO_CHAR(longtodateC(fromstate.ENTRY_END_TIME, fromstate.CENTER), 'YYYY-MM-DD HH24:MI:SS')   AS "ENTRY_END_TIME",
    CAST (tostate.KEY AS VARCHAR(255))                                                          AS "NEXT_SUB_STATE_CHANGE_ID",
    sub.CENTER                                                                                  AS "CENTER_ID",
    COALESCE(tostate.ENTRY_START_TIME,fromstate.ENTRY_END_TIME,fromstate.ENTRY_START_TIME)      AS "ETS"
FROM
    SUBSCRIPTIONS sub
JOIN
    STATE_CHANGE_LOG fromstate
ON
    fromstate.center = sub.center
    AND fromstate.id = sub.id
    AND fromstate.ENTRY_TYPE = 2
LEFT JOIN
    STATE_CHANGE_LOG tostate
ON
    fromstate.CENTER = tostate.CENTER
    AND fromstate.ID = tostate.ID
    AND fromstate.ENTRY_END_TIME = tostate.ENTRY_START_TIME
    AND tostate.ENTRY_TYPE = 2
    AND (
        tostate.ENTRY_END_TIME > tostate.ENTRY_START_TIME
        OR tostate.ENTRY_END_TIME IS NULL)
WHERE
    (
        fromstate.ENTRY_END_TIME > fromstate.ENTRY_START_TIME
        OR fromstate.ENTRY_END_TIME IS NULL)
)
 biview, params
WHERE
   ($$offset$$ = -4) OR (biview.ETS >= PARAMS.FROMDATE AND biview.ETS < PARAMS.TODATE) OR ($$offset$$ = -1 AND biview.ETS is null) OR ($$offset$$ = -3 AND biview.ETS is null)    