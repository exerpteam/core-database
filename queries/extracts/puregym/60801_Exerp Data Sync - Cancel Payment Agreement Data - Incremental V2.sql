 SELECT
     p.EXTERNAL_ID AS EXTERNALID,
     CASE
         WHEN (sub.end_date > TRUNC(longtodateC(sc.CHANGE_TIME, sub.center))) AND sc.EMPLOYEE_CENTER = 100 AND sc.EMPLOYEE_ID = 17401 THEN 'ONLINE'
         WHEN sub.end_date > TRUNC(longtodateC(sc.CHANGE_TIME, sub.center)) THEN 'MEMBER'
         ELSE 'PUREGYM'
     END                                                           AS CANCELLATIONSOURCE,
     TO_CHAR(longtodateC(sc.CHANGE_TIME, sub.center),'DD/MM/YYYY') AS CANCELLATIONDATE
 FROM
     SUBSCRIPTIONS sub
 JOIN
     SUBSCRIPTION_CHANGE sc
 ON
     sc.OLD_SUBSCRIPTION_CENTER = sub.center
 AND sc.OLD_SUBSCRIPTION_ID = sub.id
 JOIN
     PERSONS p
 ON
     p.CENTER = sub.OWNER_CENTER
 AND p.id = sub.OWNER_ID
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
 AND st.ID = sub.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
 AND ar.CUSTOMERID = p.id
 AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_REQUESTS pr
 ON
     pr.center = ar.center
 AND pr.id = ar.id
 AND pr.REQUEST_TYPE = 1
 AND pr.REQ_DATE >= CURRENT_TIMESTAMP - 7
 AND pr.state IN (2,3,4)
 AND pr.req_date >= TRUNC(longtodateC(sc.CHANGE_TIME, sub.center)) - 1
 WHERE
     st.ST_TYPE = 1
 AND sc.CANCEL_TIME IS NULL
 AND sc.OLD_SUBSCRIPTION_CENTER IN ($$scope$$)
 AND sc.TYPE = 'END_DATE'
 AND sc.CHANGE_TIME >= datetolongTZ(TO_CHAR(CURRENT_TIMESTAMP - 5, 'YYYY-MM-DD HH24:MI'), 'Europe/London')
 AND p.CURRENT_PERSON_CENTER = p.CENTER
 AND p.CURRENT_PERSON_ID = p.ID
 AND NOT EXISTS
     (
         SELECT
             1
         FROM
             SUBSCRIPTIONS os
         JOIN
             SUBSCRIPTIONTYPES ost
         ON
             ost.CENTER = os.SUBSCRIPTIONTYPE_CENTER
         AND ost.ID = os.SUBSCRIPTIONTYPE_ID
         WHERE
             os.STATE IN (2,4,8)
         AND os.OWNER_CENTER = p.CENTER
         AND os.OWNER_ID = p.ID
         AND os.END_DATE IS NULL
         AND (
                 os.center != sub.center
             OR  os.id != sub.id)
         AND (
                 ost.ST_TYPE = 0
             OR  os.END_DATE IS NULL) )
 AND (
         sub.end_date <= TRUNC(longtodateC(sc.CHANGE_TIME, sub.center))
     OR  pr.CENTER IS NULL)
