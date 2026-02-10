-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
  p.center as "Centre id", 
  c.name as "Centre name",
  p.center ||'p'|| p.id        as "Membership number",
  p.EXTERNAL_ID                AS "External_ID",
  s.center ||'ss'|| s.id       as "Subscription id",
  pr.name                       as "Subscription Name",
  pag.REF as "payment agreement ref",
pemp.fullname as "Created By",
acl.EMPLOYEE_CENTER ||'emp'|| acl.EMPLOYEE_ID as created_by_id

 
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
left JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID  
left JOIN
    PRODUCTS pr
ON
    pr.center = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.ID = s.SUBSCRIPTIONTYPE_ID
left JOIN
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
p.center in (:scope)
and pag.CREATION_TIME between (:fromdate) and (:todate)
and acl.EMPLOYEE_CENTER = 100
and acl.EMPLOYEE_id = 5006