-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-2610
https://clublead.atlassian.net/browse/ST-4117
 SELECT
     p.FULLNAME                                                                                                                                                                           AS "Full Name",
     s.center||'ss'||s.id                                                                                                                                                                 AS "Subscription ID",
     s.OWNER_CENTER||'p'||s.OWNER_ID                                                                                                                                                      AS "Person ID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END      AS "Status",
     CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS "Sub Status",
     p.SSN,
     c.NAME                             AS "Club",
     email.TXTVALUE                     AS "Email",
     mobile.TXTVALUE                    AS "Mobile Phone",
     prod.NAME                          AS "Subscription",
     s.SUBSCRIPTION_PRICE               AS "Price",
     s.START_DATE                       AS "Start Date",
     s.END_DATE                         AS "Stop Date",
     s.BINDING_END_DATE                 AS "Binding Date",
     TO_CHAR(sp.FROM_DATE,'yyyy-MM-dd') AS "From Date",
     TO_CHAR(sp.TO_DATE,'yyyy-MM-dd')   AS "To Date",
     sp.PRICE                           AS "Price Update",
     sp.COMENT                          AS "Comment",
     sp.TYPE                            AS "Type",
     CASE
         WHEN CANCELLED = 1
         THEN 'Cancelled'
         WHEN APPLIED = 1
         THEN 'Applied'
         WHEN PENDING = 1
         THEN 'Pending'
         WHEN APPROVED = 1
         THEN 'Approved'
         WHEN NOTIFIED = 1
         THEN 'Notified'
         ELSE 'Draft'
     END                                     AS "State",
     staff.CENTER || 'p' || staff.ID AS "ID Staff",
         staff.FULLNAME AS "Name Staff" , 
sp.binding
 FROM
     SUBSCRIPTIONS s
 JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.ID
 JOIN
     PRODUCTS prod
 ON
     s.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = prod.ID
 JOIN
     CENTERS c
 ON
     c.ID = s.CENTER
 JOIN
     PERSONS p
 ON
     p.center =s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = p.center
     AND email.PERSONID = p.id
     AND email.name ='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     mobile.PERSONCENTER = p.center
     AND mobile.PERSONID = p.id
     AND mobile.name ='_eClub_PhoneSMS'
 LEFT JOIN
         EMPLOYEES emp
 ON
         emp.CENTER = sp.EMPLOYEE_CENTER
         AND emp.ID = sp.EMPLOYEE_ID
 LEFT JOIN
         PERSONS staff
 ON
         staff.CENTER = emp.PERSONCENTER
         AND staff.ID = emp.PERSONID
 WHERE
     s.CENTER IN (:Scope)
     AND sp.FROM_DATE BETWEEN (:Date_From) AND (
         :Date_To)
     AND sp.CANCELLED = 0
