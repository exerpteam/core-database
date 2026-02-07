SELECT
	
	p.center || 'p' || p.id as CustomerPersonId,
	p.fullname AS CustomerName,
	epp.fullname As EmployeeFullName,
    at.ref_type,
    at.text,
	CASE
		WHEN invl.total_amount IS NULL
		THEN at.amount
		ELSE (invl.total_amount * -1)
		END AS "amount", -- Dollar amount for sub-transactions included in ar_trans entry
    CASE
        WHEN at.amount = (invl.total_amount * -1)
        THEN at.unsettled_amount
        WHEN at.amount != invl.total_amount
        THEN at.unsettled_amount * (invl.total_amount / at.amount) * -1
		WHEN invl.total_amount IS NULL 
		THEN at.unsettled_amount
    END AS "Unsettled Amount", -- Distriibuted proportionately over all sub-transactions
      CASE
        WHEN at.amount = invl.total_amount
        THEN at.unsettled_amount / (1 + ivat.rate) * -1
        WHEN at.amount != invl.total_amount
        THEN at.unsettled_amount * (invl.total_amount / at.amount) / (1 + ivat.rate) * -1
		WHEN invl.total_amount IS NULL 
		THEN at.amount
    END AS "AmountWithoutTaxes",    
    CASE
        WHEN at.amount = invl.total_amount
        THEN unsettled_amount / (1 + ivat.rate) * ivat.rate * -1
        WHEN at.amount != invl.total_amount
        THEN at.unsettled_amount * (invl.total_amount / at.amount) / (1 + ivat.rate) * ivat.rate * -1
	WHEN invl.total_amount IS NULL 
		THEN 0
    END AS "Taxes",
    zipcode.province As ProvinceOfTransaction,
    CASE WHEN at.ref_type ='ACCOUNT_TRANS' THEN a.external_id
		 WHEN at.ref_type = 'INVOICE' THEN a1.external_id
	END AS AccountExternalID,
	CASE WHEN at.ref_type ='ACCOUNT_TRANS' THEN a.globalid
	     WHEN at.ref_type = 'INVOICE' THEN a1.globalid
	END AS AccountGlobalID,	
    TO_CHAR(longtodateC(at.entry_time, 100),'YYYY-MM-DD') AS EntryTime,
	(CASE 
		 WHEN p.sex = 'C'
		 THEN 'Company'
		 ELSE 'Person'
	END) AS PersonOrCompany,
	at.status,
	at.center || 'ar' || at.id || 'art' || at.subid AS TransactionKey,
    p.external_ID AS CustomerExternalID,
    epp.external_id AS EmployeeExternalID,
    at.due_date AS DueDate

FROM 

	AR_TRANS at

	JOIN ACCOUNT_RECEIVABLES ar 
	   ON	at.ID = ar.ID AND
			at.CENTER = ar.CENTER

	LEFT JOIN account_trans acct
		ON acct.center = at.ref_center
		AND acct.id = at.ref_id
		AND acct.subid = at.ref_subid

	LEFT JOIN accounts a
		ON acct.credit_accountid = a.id 
		AND acct.credit_accountcenter = a.center
		

	LEFT JOIN invoice_lines_mt invl
    	ON at.ref_center = invl.center
	    AND at.ref_id = invl.id
    	AND at.ref_type ='INVOICE'
        
    LEFT JOIN invoicelines_vat_at_link ivat
        ON ivat.invoiceline_center = invl.center
        AND ivat.invoiceline_id = invl.id
        AND ivat.invoiceline_subid = invl.subid

	LEFT JOIN account_trans acct1
		ON invl.account_trans_center = acct1.center
		AND invl.account_trans_id = acct1.id
		AND invl.account_trans_subid = acct1.subid


	LEFT JOIN accounts a1
		ON acct1.credit_accountid = a1.id 
		AND acct1.credit_accountcenter = a1.center
		

	JOIN centers c
		ON c.id = ar.center

	JOIN zipcodes zipcode
		ON zipcode.country = c.country
		AND zipcode.zipcode = c.zipcode

	JOIN PERSONS p
		ON	p.ID = ar.CUSTOMERID AND
			p.CENTER = ar.CUSTOMERCENTER

	JOIN EMPLOYEES ep
		ON	at.employeecenter = ep.center
		AND	at.employeeid = ep.id

	JOIN PERSONS epp
		ON ep.personcenter = epp.center
		AND ep.personid = epp.id	
        
    JOIN employeesroles er
        ON ep.center = er.center
        AND ep.id = er.id
        AND er.roleid IN (
            2552 -- PDS Administrative Associate
            ,1952 -- PDS Administrative Support Specialist
            ,3776 -- PDS Auditing and Reporting Specialist
            ,5202 -- PDS Manager
            ,2958 -- Accounting Receivables
        )


WHERE
	at.employeecenter = '990' -- Home office associates
	-- AND	at.employeeid != '1' 
	AND at.employeeid !='228' -- API user
	AND at.employeeid !='5601' -- CERT API user
	AND at.employeeid !='21802' -- Common API user
	AND at.employeeid !='38805' -- Exerp support (SHA) - COVID19
    AND at.employeeid !='53401' -- Exerp support (VWO) - COVID19
    AND at.employeeid !='3202' -- Mehdi Saeidi-saei - COVID19
	AND	at.collected NOT IN
		(
			'1',
			'6'
		)

	AND	(invl.total_amount > 0 OR invl.total_amount IS NULL) -- Filter out $0 invoice lines
	AND at.unsettled_amount < 0 -- Filter out fully settled transactions
    AND ar.balance < 0 -- Filter out members without an amount owing on their payment account

    AND at.entry_time > CAST((:EntryStartTime-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 

