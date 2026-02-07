-- This is the version from 2026-02-05
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
                datetolongTZ(TO_CHAR(:fromDate, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(:toDate, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86400000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID

    )
SELECT
        sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS "Member ID",
        srp.START_DATE AS "Free period starts",
        srp.END_DATE AS "Free period ended",
        srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID",
        srp.TEXT AS "Comment",
        TO_CHAR(longtodateC(srp.ENTRY_TIME,srp.SUBSCRIPTION_CENTER),'YYYY-MM-DD HH24:MI') AS "Entry time",
        srp.TYPE
FROM
        SUBSCRIPTION_REDUCED_PERIOD srp
JOIN
        PARAMS params
        ON
                params.CenterID = srp.SUBSCRIPTION_CENTER 
JOIN
        SUBSCRIPTIONS sub
        ON
                SRP.SUBSCRIPTION_CENTER=SUB.CENTER
                AND SRP.SUBSCRIPTION_ID=SUB.ID
WHERE
        srp.SUBSCRIPTION_CENTER IN (:Scope)
        AND srp.TYPE NOT IN ('FREEZE')
        AND srp.STATE NOT IN ('CANCELLED')
        AND srp.ENTRY_TIME >= params.fromDate  
        AND srp.ENTRY_TIME <= params.toDate