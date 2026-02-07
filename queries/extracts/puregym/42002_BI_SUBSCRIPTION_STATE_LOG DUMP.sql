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
    coalesce(tostate.ENTRY_START_TIME,fromstate.ENTRY_END_TIME,fromstate.ENTRY_START_TIME)     AS "ETS"
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
)
 biview
WHERE
    biview.ETS BETWEEN $$FROMDATE$$ AND $$TODATE$$