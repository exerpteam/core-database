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
    CENTER_ID as "CENTER_ID",
    NAME          AS "CENTER_EA_NAME",
    cea.TXT_VALUE AS "CENTER_EA_VALUE",
    REPLACE(TO_CHAR(cea.LAST_EDIT_TIME,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    params,
    CENTER_EXT_ATTRS cea
WHERE    
    cea.LAST_EDIT_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
