SELECT distinct
  p.center as "Centre id", 
  c.name as "Centre name",
  p.center ||'p'|| p.id        AS "Member ID",
  p.EXTERNAL_ID                AS "External_ID",
	p.sex						AS "Gender",
  p.firstname				   AS "First Name",
	p.lastname					AS "Last Name",
	p.address1					AS "Address",
	p.city						AS "City",
	p.zipcode					AS "PostCod",
	p.country					AS "Couontry",
CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS PERSON_STATUS,
    CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
pag.IBAN as "IBAN",
pag.bank_accno as "accountNum",
pag.bic as "BIC",
pag.bank_regno as "RegNum",
pag.bank_account_holder as "Account Holder",
pag.EXPIRATION_DATE as "EpiryDate",
pag.REF as "payment agreement ref",
ch.NAME as "Clearing House",
pag.active as "Defualt",
(
        CASE pag.STATE
            WHEN 2
            THEN 'SENT'
            WHEN 3
            THEN 'FAILED'
            WHEN 4
            THEN 'OK'
            WHEN 6
            THEN 'ENDED, CLEARINGHOUSE'
            WHEN 10
            THEN 'ENDED, CREDITOR'
            ELSE 'UNKNOWN'
        END) AS "Agreement State",
---pemp.fullname as "Created By",---
longtodate(pag.CREATION_TIME) as "creation date"
---acl.EMPLOYEE_CENTER ||'emp'|| acl.EMPLOYEE_ID as created_by_id---

 
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


