SELECT distinct
  p.center as "Centre id", 
  c.name as "Centre name",
  p.center ||'p'|| p.id        as "Membership number",
  p.EXTERNAL_ID                AS "External_ID",
  s.center ||'ss'|| s.id       as "Subscription id",
  pr.name                       as "Subscription Name",
  DECODE(s.STATE,2,'ACTIVE',3,'ENDED',4,'FROZEN',7,'WINDOW',8,'CREATED','Undefined') AS "Subscription State",
  longtodate(pag.CREATION_TIME) as "DD Date",  
  DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED')as "DDI State",
pemp.fullname as "Created By",
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

Left Join
EMPLOYEES emp
ON
emp.center = acl.EMPLOYEE_CENTER
and
emp.id = acl.EMPLOYEE_ID

Left join Persons pemp

ON
pemp.center = emp.PERSONCENTER
and
pemp.id = emp.PERSONID

WHERE
    pag.state in (1,2,4)
  and p.center in (:scope)
and pag.CREATION_TIME between (:fromdate) and (:todate)
and p.persontype not in (2,6)
and s.state in (2,4)
--and p.FIRST_ACTIVE_START_DATE is NULL
AND EXISTS (SELECT 1 FROM PAYMENT_AGREEMENTS pag2 WHERE pag.CENTER = pag2.CENTER AND pag.ID = pag2.ID AND pag2.STATE IN (3,5,7,8,9)and (pag.subid-1) = pag2.subid)
and acl.state in (1) 
and not exists (SELECT 1 From agreement_change_log acl2 where acl.agreement_center = acl2.agreement_center
AND acl.agreement_id = acl2.agreement_id
and acl2.text in ('Agreement replaced'))