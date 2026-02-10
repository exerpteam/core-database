-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS BIGINT)
            AS fromdate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD')+ interval '1 day',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS todate,
            c.id                      AS centerid
        FROM
            centers c
    )
SELECT
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID                                          AS "Member ID",
    p.external_id                                                           AS "Member External ID",
    TO_CHAR(longtodateC(srp.ENTRY_TIME,srp.SUBSCRIPTION_CENTER),'YYYY-MM-DD HH24:MI') AS
    "Entry time",
    sub.center ||'ss'|| sub.id                    AS "Subscription ID",
    pr.name                                       AS "Subscription Name",
    srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID",
    staffp.fullname                               AS "Staff name",
    srp.START_DATE                                AS "Free period starts",
    srp.END_DATE                                  AS "Free period ended",
    (srp.end_date-srp.start_date+1)               AS "Number of days" ,
    srp.TEXT                                      AS "Comment",
    srp.TYPE
FROM
    SUBSCRIPTION_FREEZE_PERIOD srp
JOIN
    SUBSCRIPTIONS sub
ON
    SRP.SUBSCRIPTION_CENTER=SUB.CENTER
AND SRP.SUBSCRIPTION_ID=SUB.ID
JOIN
    subscriptiontypes st
ON
    st.center = sub.subscriptiontype_center
AND st.id = sub.subscriptiontype_id
JOIN
    products pr
ON
    pr.center = st.center
AND pr.id = st.id
JOIN
    params
ON
    params.centerid = sub.center
LEFT JOIN
    persons p
ON
    sub.OWNER_CENTER = p.center
AND sub.OWNER_ID = p.id
LEFT JOIN
    employees staff
ON
    srp.EMPLOYEE_CENTER = staff.center
AND srp.EMPLOYEE_ID = staff.id
LEFT JOIN
    persons staffp
ON
    staff.personcenter = staffp.center
AND staff.personid = staffp.id
WHERE
 --   sub.center IN (:scope)
 srp.ENTRY_TIME BETWEEN params.fromdate AND params.todate
AND srp.STATE NOT IN ('CANCELLED')