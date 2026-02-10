-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24 *3600*1000
                                                                                       AS from_date,
            CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS
            to_date
    )
SELECT DISTINCT
    t.id      AS "TASK_ID",
    tld.VALUE AS "ENQUIRY_TYPE",
    CASE
        WHEN rank() over (partition BY cp.EXTERNAL_ID ORDER BY t.CREATION_TIME) >1
        OR  scl.STATEID NOT IN (0,6,9)
        THEN 1
        ELSE 0
    END                AS "REENQUIRY",
    t.LAST_UPDATE_TIME AS "ETS"
FROM
    params,
    TASKS t
JOIN
    TASK_LOG tl
ON
    tl.TASK_ID = t.id
AND tl.TASK_ACTION_ID =11 --Choose Inquiry Type
JOIN
    TASK_LOG_DETAILS tld
ON
    tld.TASK_LOG_ID = tl.id
AND tld.name = 'RequirementType.USER_CHOICE'
JOIN
    persons p
ON
    p.center = t.PERSON_CENTER
AND p.id = t.PERSON_ID
JOIN
    persons cp
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
AND ( scl.ENTRY_END_TIME > t.CREATION_TIME
    OR  scl.ENTRY_END_TIME IS NULL)
WHERE
    t.LAST_UPDATE_TIME BETWEEN params.from_Date AND params.to_date