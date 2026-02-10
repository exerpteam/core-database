-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    cc.center||'cc'||cc.id||'id'||cc.SUBID                                      AS "CLIPCARD_ID",
    cp.EXTERNAL_ID                                                              AS "PERSON_ID",
    REPLACE(TO_CHAR(cc.CLIPS_LEFT,'FM999G999G999G999G999'),',','.')             AS "CLIPS_LEFT",
    REPLACE(TO_CHAR(cc.CLIPS_INITIAL,'FM999G999G999G999G999'),',','.')          AS "CLIPS_INITIAL",
    cc.INVOICELINE_CENTER||'inv'||cc.INVOICELINE_ID||'ln'||cc.INVOICELINE_SUBID AS "SALES_LINE_ID",
    TO_CHAR(longtodateC(cc.VALID_FROM,cc.center),'yyyy-MM-dd')                  AS "VALID_FROM_DATE",
    TO_CHAR(longtodateC(cc.VALID_UNTIL,cc.center),'yyyy-MM-dd')                 AS "VALID_UNTIL_DATE",
    CASE
        WHEN cc.BLOCKED = 1
        THEN 'true'
        WHEN cc.BLOCKED = 0
        THEN 'false'
        ELSE 'UNKNOWN'
    END AS "BLOCKED",
    CASE
        WHEN cc.CANCELLED = 1
        THEN 'true'
        WHEN cc.CANCELLED = 0
        THEN 'false'
        ELSE 'UNKNOWN'
    END                                                                        AS "CANCELLED",
    TO_CHAR(longtodateC(cc.CANCELLATION_TIME, cc.center),'yyyy-MM-dd HH24:MM') AS "CANCELLATION_TIME",
    cstaff.external_id                                                         AS "ASSIGNED_EMPLOYEE_ID",
    cc.center                                                                  AS "CENTER_ID",
    REPLACE(TO_CHAR(cc.LAST_MODIFIED,'FM999G999G999G999G999'),',','.')         AS "ETS"
FROM
    params,
    CLIPCARDS cc
JOIN
    PERSONS p
ON
    p.center = cc.OWNER_CENTER
    AND p.id = cc.OWNER_ID
JOIN
    persons cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    persons staff
ON
    staff.center = cc.assigned_staff_center
    AND staff.id = cc.assigned_staff_id
LEFT JOIN
    persons cstaff
ON
    cstaff.center = staff.transfers_current_prs_center
    AND cstaff.id = staff.transfers_current_prs_id
WHERE
    cc.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
