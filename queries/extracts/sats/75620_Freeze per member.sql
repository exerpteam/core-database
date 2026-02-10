-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         sub.OWNER_CENTER || 'p' || sub.OWNER_ID AS "Member ID",
         srp.START_DATE AS "Free period starts",
         srp.END_DATE AS "Free period ended",
         (srp.end_date-srp.start_date+1) as "number of days" ,
        -- srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID",
        -- staffp.fullname,
         srp.TEXT AS "Comment",
       --   srp.EMPLOYEE_CENTER ||'emp'|| srp.EMPLOYEE_ID AS "Staff ID",
      --   staffp.fullname as "employee name",
 TO_CHAR(longtodateC(srp.ENTRY_TIME,srp.SUBSCRIPTION_CENTER),'YYYY-MM-DD HH24:MI') AS "Entry time",
         srp.TYPE
 FROM
         SUBSCRIPTION_REDUCED_PERIOD srp
 JOIN
         SUBSCRIPTIONS sub
         ON
                 SRP.SUBSCRIPTION_CENTER=SUB.CENTER
                 AND SRP.SUBSCRIPTION_ID=SUB.ID
 Left join persons p
 on
 sub.OWNER_CENTER = p.center
 and
 sub.OWNER_ID = p.id
 LEFT JOIN employees staff
 ON
     srp.EMPLOYEE_CENTER = staff.center
     AND srp.EMPLOYEE_ID = staff.id
 LEFT JOIN persons staffp
 ON
     staff.personcenter = staffp.center
     AND staff.personid = staffp.id
 WHERE
         p.external_id = (:externalid)
         AND srp.TYPE IN ('FREEZE')
         AND srp.STATE NOT IN ('CANCELLED')
         AND srp.TEXT = 'Service | Freeze | SATS Rewards​'
