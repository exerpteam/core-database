 SELECT CASE
         WHEN (sub.end_date >  date_trunc('day',longtodateC(sc.CHANGE_TIME, sub.center))) AND sc.EMPLOYEE_CENTER =:APICenter
AND sc.EMPLOYEE_ID = :APIId THEN 'ONLINE'
         ELSE 'PUREGYM'
     END                                                           AS CANCELLATIONSOURCE,
     sc.CHANGE_TIME AS CANCELLATIONDATE
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
 WHERE
p.Center in (:Center)
	AND p.ID in (:MemberId)

 AND st.ST_TYPE = 1
 AND sc.CANCEL_TIME IS NULL
 AND sc.TYPE = 'END_DATE'
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