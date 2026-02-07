SELECT distinct
  p.center as "Centre id", 
  c.name as "Centre name",
  p.center ||'p'|| p.id        AS "Member ID",
  p.EXTERNAL_ID                AS "External_ID",
  p.fullname				   AS "Member Name",
ch.NAME as "Clearing House",
pag.active as "Active",
pemp.fullname as "Created By",
longtodate(pag.CREATION_TIME) as "creation date",
acl.EMPLOYEE_CENTER ||'emp'|| acl.EMPLOYEE_ID as created_by_id,
pag.bank_account_holder as "Account Holder",
pag.IBAN as "IBAN",
pag.bank_accno as "accountNum",
pag.bic as "BIC",
pag.bank_regno as "RegNum",
pag.REF as "payment agreement ref"

 
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

JOIN CLEARINGHOUSES ch 
                ON ch.ID = pag.clearinghouse


WHERE
pag.State in (1,2,4,13)
and ch.NAME like 'DD%%'
and p.center in (:scope)
and p.Status in (:status)
and pag.CREATION_TIME between (:fromdate) and (:todate)

