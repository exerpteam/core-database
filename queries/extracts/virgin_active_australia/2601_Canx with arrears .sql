-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  
    C.Shortname AS "Club",

    CASE p.STATUS 
        WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' 
    END AS PERSON_STATUS,

    CASE S.State  
        WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED'
        ELSE 'Undefined'
    END AS Subscription_State,

    CASE S.Sub_State  
        WHEN 1 THEN 'NONE' WHEN 2 THEN 'N/A' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED'
        WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED'
        WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' 
    END AS SUBSCRIPTION_SUBSTATE,

    p.center || 'p' || p.id AS memberid,
email.TXTVALUE as email,
    PR.NAME AS Subscription,
    S.Start_date,
    TO_CHAR(S.END_DATE,'yyyy-MM-dd') AS Cancellation_date,
    TO_CHAR(S.BINDING_END_DATE,'yyyy-MM-dd') AS Contract_End_Date,

    ACCOUNT_RECEIVABLES.BALANCE AS Outstanding_Balance,

    TO_CHAR(longtodateC(ci.max_checkin_time, ci.person_center), 'DD-MM-YYYY') AS Last_Attendance_Day,

    prq_latest.REJECTED_REASON_CODE AS reasoncode,
    prq_latest.xfr_info AS reason

FROM ACCOUNT_RECEIVABLES
JOIN persons p
    ON ACCOUNT_RECEIVABLES.customercenter = p.center 
   AND ACCOUNT_RECEIVABLES.customerid = p.id

JOIN Centers C 
    ON C.ID = p.Center

LEFT JOIN CASHCOLLECTIONCASES ccc
    ON ccc.PERSONCENTER = ACCOUNT_RECEIVABLES.customercenter
   AND ccc.PERSONID = ACCOUNT_RECEIVABLES.customerid
   AND ccc.CLOSED = 0
   AND ccc.MISSINGPAYMENT = 1

LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             p.center=email.PERSONCENTER
             AND p.id=email.PERSONID
             AND email.name='_eClub_Email'
             --AND email.TXTVALUE IS NOT NULL

LEFT JOIN LATERAL (
    SELECT *
    FROM SUBSCRIPTIONS S
    WHERE S.OWNER_CENTER = p.CENTER
      AND S.OWNER_ID = p.ID
      AND S.STATE IN (3,7)
    ORDER BY S.START_DATE DESC
    FETCH FIRST 1 ROW ONLY
) S ON 1=1

JOIN SUBSCRIPTIONTYPES ST
    ON ST.CENTER = S.SUBSCRIPTIONTYPE_CENTER
   AND ST.id = S.SUBSCRIPTIONTYPE_ID

JOIN PRODUCTS PR
    ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
   AND PR.id = S.SUBSCRIPTIONTYPE_ID

LEFT JOIN (
    SELECT 
        person_center,
        person_id,
        MAX(checkin_time) AS max_checkin_time
    FROM CHECKINS
    GROUP BY person_center, person_id
) ci 
    ON p.center = ci.person_center 
   AND p.id = ci.person_id

LEFT JOIN LATERAL (
    SELECT pr1.*
    FROM PAYMENT_REQUESTS pr1
    WHERE pr1.CENTER = ACCOUNT_RECEIVABLES.CENTER
      AND pr1.ID = ACCOUNT_RECEIVABLES.ID
      AND pr1.STATE NOT IN (1,2,3,4)
    ORDER BY pr1.REQ_DATE DESC
    FETCH FIRST 1 ROW ONLY
) prq_latest ON 1=1

WHERE ACCOUNT_RECEIVABLES.CENTER IN (:center)
  AND ACCOUNT_RECEIVABLES.BALANCE < 0
  AND PR.NAME NOT LIKE 'PT%' 
  AND P.status = '2';
