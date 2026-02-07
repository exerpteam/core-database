 SELECT DISTINCT
     p.center                                                                                                                                                                                                        AS "Centre id",
     c.name                                                                                                                                                                                                        AS "Centre name",
     p.center ||'p'|| p.id                                                                                                                                                                                                        AS "Membership number",
     p.EXTERNAL_ID                                                                                                                                                                                                        AS "External_ID",
     s.center ||'ss'|| s.id                                                                                                                                                                                                        AS "Subscription id",
     pr.name                                                                                                                                                                                                        AS "Subscription Name",
     longtodatec(pag.CREATION_TIME,pag.center)                                                                                                                                                                                                        AS "DD Date",
     CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN  'Signature missing'  ELSE 'UNDEFINED' END AS "DDI State",
     pemp.fullname                                                                                                                                                                                                        AS "Created By",
     pag.id,
     pag.subid
 FROM
     PAYMENT_AGREEMENTS pag
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.ACTIVE_AGR_CENTER = pag.center
     AND pac.ACTIVE_AGR_ID = pag.ID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     pac.center = ar.center
     AND pac.ID = ar.ID
     AND ar.AR_TYPE = 4
 JOIN
     PERSONS p
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.ID
 JOIN
     PRODUCTS pr
 ON
     pr.center = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 JOIN
     agreement_change_log acl
 ON
     acl.agreement_center = pag.center
     AND acl.agreement_id = pag.id
     AND acl.agreement_subid = pag.subid
 LEFT JOIN
     STATE_CHANGE_LOG scl
 ON
     scl.ENTRY_TYPE = 5
     AND scl.BOOK_START_TIME < acl.ENTRY_TIME
     AND (
         scl.BOOK_END_TIME > acl.ENTRY_TIME
         OR scl.BOOK_END_TIME IS NULL)
     AND (
         scl.STATEID IN (0,1,5)
         OR scl.SUB_STATE = 3) -- Exclude "NotApplicable" , "NonMember" , "ExMember" (-- Exclude "Rejoiner")
     AND scl.CENTER = p.center
     AND scl.ID = p.ID
 LEFT JOIN
     EMPLOYEES emp
 ON
     emp.center = acl.EMPLOYEE_CENTER
     AND emp.id = acl.EMPLOYEE_ID
 LEFT JOIN
     Persons pemp
 ON
     pemp.center = emp.PERSONCENTER
     AND pemp.id = emp.PERSONID
 WHERE
     pag.state IN (1,2,4)
     AND p.center IN (:scope)
     AND pag.CREATION_TIME BETWEEN (:fromdate) AND (
         :todate)
     AND p.persontype NOT IN (2,6)
     AND s.state IN (2,4)
     AND scl.ID IS NULL
     --and p.FIRST_ACTIVE_START_DATE is NULL,
     AND EXISTS
     (
         SELECT
             1
         FROM
             PAYMENT_AGREEMENTS pag2
         WHERE
             pag.CENTER = pag2.CENTER
             AND pag.ID = pag2.ID
             AND pag2.STATE IN (3,5,7,8,9))
     AND acl.state IN (1)
     AND NOT EXISTS
     (
         SELECT
             1
         FROM
             agreement_change_log acl2
         WHERE
             acl.agreement_center = acl2.agreement_center
             AND acl.agreement_id = acl2.agreement_id
             AND acl2.text IN ('Agreement replaced'))
