SELECT

	p.external_ID AS CustomerExternalID,
	p.center || 'p' || p.id as CustomerPersonId,
	p.fullname AS CustomerName,
	(CASE
            WHEN at.payreq_spec_center is not null
            THEN prs.ref
            ELSE 'Unbilled'
	    END) 
		as DocumentNumber,
	(CASE
		When at.payreq_spec_center is not null
		then pr.req_date
		else null
		end)
		as DocumentDate,
	longtodateC(at.entry_time, 100) AS EntryTime,	
	at.due_date AS DueDate,
	at.amount AS OriginalAmount,
	(at.unsettled_amount - at.amount) AS SettledAmount,
	at.unsettled_amount AS OpenAmount,
	--ar.balance as CompanyOpenBalance,
	pea.txtvalue AS CompanyType,
	accountManager.fullname AS KeyAccountManager,
	ep.external_ID AS EmployeeExternalID,
	epp.fullname As EmployeeFullName,
	--Company Contact
	--Company e-mail (invoice e-mail)
	at.status,
	at.ref_type,
	at.text



FROM 
	AR_TRANS at

	JOIN ACCOUNT_RECEIVABLES ar 
	   ON	at.ID = ar.ID AND
			at.CENTER = ar.CENTER

	JOIN PERSONS p
		ON	p.ID = ar.CUSTOMERID AND
			p.CENTER = ar.CUSTOMERCENTER
	

	
	JOIN PERSON_EXT_ATTRS pea
		ON 	pea.personID = p.ID AND
			pea.personcenter = p.center

	JOIN EMPLOYEES ep
		ON	at.employeecenter = ep.center
		AND	at.employeeid = ep.id

	JOIN PERSONS epp
		ON ep.personcenter = epp.center
		AND ep.personid = epp.id	


--at.payreq_spec_center is not null 
left join payment_request_specifications prs
	on at.payreq_spec_center = prs.center
	and at.payreq_spec_id = prs.id
	and at.payreq_spec_subid = prs.subid

left join payment_requests pr
	on pr.center = prs.center
	and pr.id = prs.id
	and pr.subid = prs.subid

	LEFT JOIN relatives relaccount
        ON relaccount.center = p.center
           AND relaccount.id = p.id
           AND relaccount.rtype=10
           AND relaccount.status = 1

	LEFT JOIN persons accountManager
        ON accountManager.center = relaccount.relativecenter
           AND accountManager.id = relaccount.relativeid

WHERE
	longtodateC(at.entry_time, p.center) <= ($$ReportDate$$)
AND
	pea.name = 'COMPANYTYPE'
--AND
--	at.unsettled_amount <> 0
AND
	p.sex = 'C'