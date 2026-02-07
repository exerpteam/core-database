-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,( SELECT
            scl.KEY                                                                         AS "PERSON_CA_LOG_ID",
            cp.EXTERNAL_ID                                                                  AS "PERSON_ID",
            TO_CHAR(longtodateC(scl.ENTRY_START_TIME, scl.CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "ENTRY_START_TIME",
            r.RELATIVECENTER||'p'||r.RELATIVEID||'rpt'||r.RELATIVESUBID                     AS "COMPANY_AGREEMENT_ID",
            CASE
                WHEN scl.STATEID = 0
                THEN 'LEAD'
                WHEN scl.STATEID = 1
                THEN 'ACTIVE'
                WHEN scl.STATEID = 2
                THEN 'INACTIVE'
                WHEN scl.STATEID = 3
                THEN 'BLOCKED'
            END                  AS "STATE",
            scl.ENTRY_START_TIME AS "ETS"
        FROM
            FW.STATE_CHANGE_LOG scl
        JOIN
            FW.RELATIVES r
        ON
            r.center = scl.center
            AND r.id = scl.id
            AND r.SUBID = scl.SUBID
            AND r.rtype = 3
        JOIN
            FW.PERSONS p
        ON
            p.center = r.center
            AND p.id = r.ID
        JOIN
            FW.PERSONS cp
        ON
            cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        WHERE
            scl.ENTRY_END_TIME-scl.ENTRY_START_TIME > 1000
            OR scl.ENTRY_END_TIME IS NULL) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE