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
    CAST ( cc_usage.ID AS VARCHAR(255))                                              AS "ID",
    cc_usage.CARD_CENTER||'cc'||cc_usage.CARD_ID||'id'||cc_usage.CARD_SUBID          AS "CLIPCARD_ID",
    cc_usage.TYPE                                                                    AS "TYPE",
    cc_usage.STATE                                                                   AS "STATE",
    cstaff.EXTERNAL_ID                                                               AS "EMPLOYEE_ID",
    REPLACE(TO_CHAR(cc_usage.CLIPS,'FM999G999G999G999G999'),',','.')                            AS "CLIPS",
    REPLACE(TO_CHAR(cc_usage.clipcard_usage_commission,'FM999G999G999G999G999'),',','.')        AS "COMMISSION_UNITS",
    TO_CHAR(longtodateC(cc_usage.TIME,cc_usage.CARD_CENTER),'yyyy-MM-dd HH24:MI:SS') AS "USAGE_TIME",
    cc_usage.CARD_CENTER                                                             AS "CENTER_ID",
    REPLACE(TO_CHAR(cc_usage.LAST_MODIFIED,'FM999G999G999G999G999'),',','.')         AS "ETS"
FROM
    params,
    CARD_CLIP_USAGES cc_usage
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = cc_usage.EMPLOYEE_CENTER
    AND emp.id = cc_usage.EMPLOYEE_ID
LEFT JOIN
    PERSONS staff
ON
    staff.center = emp.PERSONCENTER
    AND staff.id = emp.PERSONID
LEFT JOIN
    PERSONS cstaff
ON
    cstaff.center = staff.TRANSFERS_CURRENT_PRS_CENTER
    AND cstaff.id = staff.TRANSFERS_CURRENT_PRS_ID
WHERE
    cc_usage.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
and cstaff.EXTERNAL_ID in (:staff_externalID) 