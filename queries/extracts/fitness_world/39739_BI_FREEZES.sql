-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI')) AS BIGINT) END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS BIGINT) AS TODATE
    )
SELECT
    CAST ( f.ID AS VARCHAR(255))                                             "FREEZE_ID",
    f.SUBSCRIPTION_CENTER || 'ss' || f.SUBSCRIPTION_ID                       "SUBSCRIPTION_ID",
    CAST ( f.SUBSCRIPTION_CENTER AS VARCHAR(255))                            "SUBSCRIPTION_CENTER_ID",
    TO_CHAR(f.START_DATE, 'YYYY-MM-DD')                                      "START_DATE",
    TO_CHAR(f.END_DATE, 'YYYY-MM-DD')                                        "END_DATE",
    f.STATE AS                                                               "STATE",
    f.TYPE  AS                                                               "TYPE",
    f.TEXT                                                                   "REASON",
    TO_CHAR(longtodateC(f.ENTRY_TIME, f.SUBSCRIPTION_CENTER), 'YYYY-MM-DD')  "ENTRY_DATE",
    TO_CHAR(longtodateC(f.CANCEL_TIME, f.SUBSCRIPTION_CENTER), 'YYYY-MM-DD') "CANCEL_DATE",
    REPLACE(TO_CHAR(f.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS     "ETS"        
FROM
    params,
    SUBSCRIPTION_FREEZE_PERIOD f
WHERE
    f.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
