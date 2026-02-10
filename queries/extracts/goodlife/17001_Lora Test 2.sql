-- The extract is extracted from Exerp on 2026-02-08
-- trying to get info about a list of agts
SELECT 
        art.amount,
        actr.info as memberid,
        actr.text, 
		'fin trans' AS type,
        actr.aggregated_transaction_center || 'agt' || actr.aggregated_transaction_id AS agtid,
		agt.book_date AS AGT_Date,
		actr.aggregated_transaction_center AS agt_center, 
        agt.debit_account_external_id AS debit_account,
		dacct.name AS debit_account_name, 
        agt.credit_account_external_id AS credit_account,
		cacct.name AS credit_account_name,
        art.employeecenter || 'emp'  ||  art.employeeid as employeeID,
        p.firstname || ' ' || p.lastname As EmployeeName,
		TO_CHAR(longtodateTZ(actr.trans_time, 'America/Toronto'),'YYYY-MM-DD') TransTime,
        TO_CHAR(longtodateTZ(actr.entry_time, 'America/Toronto'),'YYYY-MM-DD') EntryTime,
		actr.center || 'acc' || actr.id || 'tr' || actr.subid AS fin_trans_id


FROM 
        account_trans actr
JOIN 
        aggregated_transactions agt 
        ON actr.aggregated_transaction_center = agt.center 
        AND actr.aggregated_transaction_id = agt.id
LEFT JOIN 
        ar_trans art 
        ON art.ref_center = actr.center 
        AND art.ref_id = actr.id 
        AND art.ref_subid = actr.subid 
        AND art.ref_type = 'ACCOUNT_TRANS'

JOIN Employees e
		ON e.center = art.employeecenter
		AND e.id = art.employeeid

JOIN Persons p
		ON p.center = e.personcenter
		AND p.id = e.personid

JOIN Accounts dacct
		ON dacct.center = actr.debit_accountcenter
		AND dacct.id = actr.debit_accountid

JOIN Accounts cacct
		ON cacct.center = actr.credit_accountcenter
		AND cacct.id = actr.credit_accountid

WHERE
        agt.book_date >= :date_from
        AND agt.book_date <= :date_to
        AND actr.info_type = 11
        AND actr.aggregated_transaction_center || 'agt' || actr.aggregated_transaction_id IN ($$AGTID$$)