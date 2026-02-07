WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
                datetolongTZ(TO_CHAR(:fromDate, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(:toDate, 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86400000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN SATS.COUNTRIES co ON c.COUNTRY = co.ID

    )
SELECT
        sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS "Member ID",
        srp.START_DATE AS "Free period starts",
        srp.END_DATE AS "Free period ended",
        (srp.end_date-srp.start_date+1) as "number of days" ,
        srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID",
        staffp.fullname,
        srp.TEXT AS "Comment",
         srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID", 
        staffp.fullname as "employee name",
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
LEFT JOIN employees staff
ON
    srp.EMPLOYEE_CENTER = staff.center
    AND srp.EMPLOYEE_ID = staff.id
LEFT JOIN persons staffp
ON
    staff.personcenter = staffp.center
    AND staff.personid = staffp.id
WHERE
        srp.SUBSCRIPTION_CENTER IN (:Scope)
        AND srp.TYPE NOT IN ('FREEZE')
        AND srp.STATE NOT IN ('CANCELLED')
        AND srp.START_DATE between (:fromDate)  
        AND(:toDate)