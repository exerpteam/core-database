-- This is the version from 2026-02-05
--  
SELECT DISTINCT
	p.center||'p'||p.ID "Medlems ID",
	p.FULLNAME AS "Medlems navn",
	case p.status when 0 then 'Lead' when 1 then 'Active' when 2 then 'Inactive' when 3 then 'TemporaryInactive' when 4 then 'Transferred' when 5 then 'Duplicate' when 6 then 'Prospect' when 7 then 'Deleted' when 8 then 'Anonymized' when 9 then 'Contact' else 'Undefined' end AS "Person status",
	curr_ch.NAME "Nuværende aftale type",
	Case curr_agree.STATE When 1 Then 'Oprettet' When 2 Then 'Oprettelse sendt' When 3 Then 'Fejlet' When 4 Then 'OK' When 5 Then 'Afsluttet bank' When 6 Then 'Afsluttet PBS' When 7 Then 'Afsluttet kunde' When 8 Then 'Afmeld' When 9 Then 'Afmeldelse sendt' When 10 Then 'Afsluttet kreditor' When 13 Then 'Aftale ikke nødvendigt' When 14 Then 'Mangelfuld' Else 'Undefined' End AS "Nuværende aftale status",
TO_CHAR(longtodate(acl_old.ENTRY_TIME), 'dd-MM-yyyy HH24:MI') AS "Oprettelses tid",
	emp.CENTER ||'emp'|| emp.ID AS "Personale ID",
	staff.FULLNAME AS "Personale navn"
FROM 
	PERSONS p

JOIN 
	ACCOUNT_RECEIVABLES ar 
ON 
	ar.customercenter = p.center 
AND ar.customerid = p.id 
AND ar.ar_type = 4

JOIN 
	PAYMENT_ACCOUNTS pa 
ON 
	pa.center = ar.center 
AND pa.id = ar.id 

JOIN 
	PAYMENT_AGREEMENTS curr_agree 
ON
	curr_agree.center = pa.active_agr_center
AND curr_agree.ID = pa.active_agr_id 
AND curr_agree.subid = pa.active_agr_subid
AND curr_agree.ACTIVE = 1
AND curr_agree.ENDED_DATE is null
AND curr_agree.CREDITOR_ID = 'Adyen-FW-PG'
--AND curr_agree.PAYMENT_CYCLE_CONFIG_ID = 1009

JOIN
	CLEARINGHOUSES curr_ch 
ON
	curr_ch.ID = curr_agree.clearinghouse

JOIN
	AGREEMENT_CHANGE_LOG acl_curr
ON
	curr_agree.CENTER = acl_curr.AGREEMENT_CENTER
AND curr_agree.ID = acl_curr.AGREEMENT_ID
AND	curr_agree.SUBID = acl_curr.AGREEMENT_SUBID

JOIN
	PAYMENT_AGREEMENTS old_agree
ON
	old_agree.center = pa.active_agr_center
AND old_agree.ID = pa.active_agr_id 
AND old_agree.ACTIVE = 0
AND old_agree.CREDITOR_ID = 'FW_ADYEN'

JOIN 
	AGREEMENT_CHANGE_LOG acl_old
ON
	old_agree.CENTER = acl_old.AGREEMENT_CENTER
AND old_agree.ID = acl_old.AGREEMENT_ID
AND	old_agree.SUBID = acl_old.AGREEMENT_SUBID

JOIN
	CLEARINGHOUSES old_ch 
ON
	old_ch.ID = old_agree.clearinghouse

JOIN
	EMPLOYEES emp
ON
	acl_old.EMPLOYEE_CENTER = emp.CENTER
AND acl_old.EMPLOYEE_ID = emp.ID

JOIN
	PERSONS staff
ON
	emp.PERSONCENTER = staff.CENTER
AND	emp.PERSONID = staff.ID
	
WHERE 
	p.Status in (1,3,9)
AND p.SEX != 'C'
AND p.Center in (:Scope)
--AND p.center||'p'||p.ID in (member)
AND acl_old.LOG_DATE BETWEEN :FROMDATE AND :TODATE
AND acl_old.ENTRY_TIME = (	SELECT 
								MAX(acl.ENTRY_TIME) 
							FROM
								AGREEMENT_CHANGE_LOG acl 
							WHERE 	
								acl.AGREEMENT_CENTER = acl_old.AGREEMENT_CENTER
							AND acl.AGREEMENT_ID = acl_old.AGREEMENT_ID
							AND	acl.AGREEMENT_SUBID = acl_old.AGREEMENT_SUBID 
							AND	acl.EMPLOYEE_CENTER = 114
							AND acl.EMPLOYEE_ID = 267682
							)

ORDER BY
p.center||'p'||p.ID
