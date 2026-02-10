-- The extract is extracted from Exerp on 2026-02-08
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
    cc.CENTER || 'cc' || cc.ID          "DEBT_CASE_ID",
    cc.CENTER                           "CENTER_ID",
    cp.EXTERNAL_ID                      "PERSON_ID",
    TO_CHAR(cc.STARTDATE, 'YYYY-MM-DD') "START_DATE",
    REPLACE(REPLACE(REPLACE(to_char(cc.AMOUNT , 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')   AS "AMOUNT",
    CASE
        WHEN cc.CLOSED = 0
        THEN 'FALSE'
        WHEN cc.CLOSED = 1
        THEN 'TRUE'
    END                                                             AS "CLOSED",
    TO_CHAR(longtodateC(cc.CLOSED_DATETIME,cc.CENTER),'yyyy-MM-dd') AS "CLOSED_DATE",
    cc.CURRENTSTEP                                                  AS "CURRENT_STEP",
    REPLACE(TO_CHAR(cc.LAST_MODIFIED ,'FM999G999G999G999G999'),',','.')  AS "ETS"  
FROM
    params,
    CASHCOLLECTIONCASES cc
JOIN
    PERSONS p
ON
    p.center = cc.PERSONCENTER
    AND p.ID = cc.PERSONID
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
WHERE
    cc.MISSINGPAYMENT = 1
AND cc.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
