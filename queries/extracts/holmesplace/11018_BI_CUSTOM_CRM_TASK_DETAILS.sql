WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT DISTINCT
            t.id                                AS "TASK_ID",
            DECODE(tl.id,NULL,'LEAD','WALK_IN') AS "ENQUIRY_TYPE",
            CASE
                WHEN rank() over (partition BY cp.EXTERNAL_ID ORDER BY t.CREATION_TIME) >1
                    OR scl.STATEID NOT IN (0,6,9)
                THEN 1
                ELSE 0
            END                                            AS "REENQUIRY",
            greatest(NVL(tl.ENTRY_TIME,0),t.CREATION_TIME) AS "ETS"
        FROM
            TASKS t
        LEFT JOIN
            TASK_LOG tl
        ON
            tl.TASK_ID = t.id
            AND tl.TASK_ACTION_ID =600 --Walkin
        JOIN
            PERSONS p
        ON
            p.center = t.PERSON_CENTER
            AND p.id = t.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.center = p.center
            AND scl.id = p.id
            AND scl.ENTRY_TYPE = 1
            AND scl.ENTRY_START_TIME<=t.CREATION_TIME
            AND (
                scl.ENTRY_END_TIME > t.CREATION_TIME
                OR scl.ENTRY_END_TIME IS NULL) ) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE