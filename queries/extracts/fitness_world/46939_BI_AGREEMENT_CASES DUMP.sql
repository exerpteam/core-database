-- This is the version from 2026-02-05
--  
SELECT
 cc.CENTER || 'cc' || cc.ID          "AGREEMENT_CASE_ID",
    cc.CENTER                           "CENTER_ID",
    cp.EXTERNAL_ID                      "PERSON_ID",
    TO_CHAR(cc.STARTDATE, 'YYYY-MM-DD') "START_DATE",
    CASE
        WHEN cc.CLOSED = 0
        THEN 'FALSE'
        WHEN cc.CLOSED = 1
        THEN 'TRUE'
    END              AS "CLOSED",
    TO_CHAR(longtodateC(cc.CLOSED_DATETIME,cc.CENTER),'yyyy-MM-dd') AS "CLOSED_DATE",
    REPLACE(TO_CHAR(cc.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    CASHCOLLECTIONCASES cc
JOIN
    PERSONS p
ON
    p.center = cc.PERSONCENTER
    AND p.ID = cc.PERSONID
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    cc.MISSINGPAYMENT = 0

