-- This is the version from 2026-02-05
--  
SELECT
    CAST ( cc_usage.ID AS VARCHAR(255))                                              AS "ID",
    cc_usage.CARD_CENTER||'cc'||cc_usage.CARD_ID||'id'||cc_usage.CARD_SUBID          AS "CLIPCARD_ID",
    cc_usage.TYPE                                                                    AS "TYPE",
    cc_usage.STATE                                                                   AS "STATE",
    cstaff.EXTERNAL_ID                                                               AS "EMPLOYEE_ID",
    cc_usage.CLIPS                                                                   AS "CLIPS",
    cc_usage.clipcard_usage_commission                                               AS "COMMISSION_UNITS",
    TO_CHAR(longtodateC(cc_usage.TIME,cc_usage.CARD_CENTER),'yyyy-MM-dd HH24:MI:SS') AS "USAGE_TIME",
    cc_usage.CARD_CENTER                                                             AS "CENTER_ID",
    REPLACE(TO_CHAR(cc_usage.LAST_MODIFIED,'FM999G999G999G999G999'),',','.')         AS "ETS"
FROM
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