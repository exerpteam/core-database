 SELECT
     c.name                                                             AS center,
     s.OWNER_CENTER||'p'||s.OWNER_ID                                    AS MemberID,
     pr.NAME                                                            AS "Subscription Name",
     s.END_DATE,
     COALESCE(convert_from(je.big_text, 'UTF8'), je.TEXT)               AS Note,
     emp.CENTER||'emp'||emp.id AS "Employee",
     staff.FULLNAME            AS "Employee Name"
 FROM
     SUBSCRIPTIONS s
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
     EMPLOYEES emp
 ON
     emp.CENTER = s.CREATOR_CENTER
     AND emp.id = s.CREATOR_ID
 JOIN
     PERSONS staff
 ON
     staff.CENTER = emp.PERSONCENTER
     AND staff.id = emp.PERSONID
 left JOIN
     JOURNALENTRIES je
 ON
     je.PERSON_CENTER = s.OWNER_CENTER
     AND je.PERSON_ID = s.OWNER_ID
     and je.CREATION_TIME between s.CREATION_TIME -1000*60*2 and s.CREATION_TIME +1000*60*2
 JOIN
     CENTERS c
 ON
     c.id = s.CENTER
 WHERE
     (
         pr.GLOBALID = 'FREE_COMPLEMENTARY'
         OR (
             s.SUBSCRIPTION_PRICE = 0
             AND pr.PRICE !=0))
      AND s.OWNER_CENTER IN ($$scope$$)
     AND s.STATE IN (2,4)-- and s.OWNER_CENTER = 3 and s.OWNER_ID = 5672
     and s.CREATION_TIME between dateToLong(to_char(CURRENT_TIMESTAMP -7, 'YYYY-MM-dd HH24:MI')) and dateToLong(to_char(CURRENT_TIMESTAMP, 'YYYY-MM-dd HH24:MI'))
