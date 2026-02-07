-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            c.id,
            CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE - interval '5 days'
            AS TIMESTAMP))) AS bigint)*1000 AS FROMDATE,
            (CAST(extract(epoch FROM timezone('Europe/London',CAST(CURRENT_DATE + interval '1 day'
            AS TIMESTAMP))) AS bigint)*1000) AS TODATE
        FROM
            centers c
        WHERE
            id IN ($$scope$$)
    )
SELECT
    biview.*
FROM
    (
        SELECT
            CAST ( scl.KEY AS VARCHAR(255))                       AS "SUB_STATE_CHANGE_ID",
            CAST ( scl.CENTER AS VARCHAR(255))                    AS "SUBSCRIPTION_CENTER_ID",
            scl.CENTER || 'ss' || scl.ID                          AS "SUBSCRIPTION_ID",
            BI_DECODE_FIELD ('SUBSCRIPTIONS','STATE',scl.STATEID)       AS "STATE",
            BI_DECODE_FIELD ('SUBSCRIPTIONS','SUB_STATE',scl.SUB_STATE) AS "SUB_STATE",
            LONGTODATETZ(scl.ENTRY_START_TIME, 'Europe/London') AS "ENTRY_START_TIME",
            LONGTODATETZ(scl.ENTRY_END_TIME, 'Europe/London') AS "ENTRY_END_TIME",
            CAST (lead(scl.key) over (partition BY scl.center,scl.id ORDER BY
            CASE
                WHEN scl.STATEID IN (3,7)
                THEN scl.BOOK_END_TIME
                ELSE scl.ENTRY_END_TIME
            END) AS VARCHAR(255))                             AS "NEXT_SUB_STATE_CHANGE_ID",
            scl.CENTER                                        AS "CENTER_ID",
            COALESCE(scl.ENTRY_END_TIME,scl.ENTRY_START_TIME) AS "ETS"
        FROM
            STATE_CHANGE_LOG scl
        JOIN
            PARAMS
        ON
            params.id = CAST(CAST ( scl.CENTER AS VARCHAR(255)) AS INT)
        WHERE
            scl.ENTRY_TYPE = 2
        AND COALESCE(scl.ENTRY_END_TIME,scl.ENTRY_START_TIME) >= PARAMS.FROMDATE
        AND COALESCE(scl.ENTRY_END_TIME,scl.ENTRY_START_TIME) < PARAMS.TODATE) biview
JOIN
    PARAMS
ON
    params.id = CAST(biview."SUBSCRIPTION_CENTER_ID" AS INT)
WHERE
    biview."ETS" >= PARAMS.FROMDATE
AND biview."ETS" < PARAMS.TODATE