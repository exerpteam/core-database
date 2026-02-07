SELECT 
        art.amount,
        actr.info as memberid,
        actr.text, 
        actr.aggregated_transaction_center || 'agt' || actr.aggregated_transaction_id AS agtid,
		actr.aggregated_transaction_center AS agt_center, 
        agt.debit_account_external_id AS debit_account,
		dacct.name AS debit_account_name, 
        agt.credit_account_external_id AS credit_account,
		cacct.name AS credit_account_name,
        art.employeecenter || 'emp'  ||  art.employeeid as employeeID,
        p.firstname || ' ' || p.lastname As EmployeeName,
		longtodateTZ(actr.trans_time, 'America/Toronto') TransTime,
        longtodateTZ(actr.entry_time, 'America/Toronto') EntryTime,
		agt.book_date AS AGT_Date,
		actr.center || 'acc' || actr.id || 'tr' || actr.subid AS fin_trans_id,
		actr.debit_transaction_center || 'acc' || actr.debit_transaction_id || 'tr' || actr.debit_transaction_subid AS d_link_fin_trans_id,
		dlinkdacct.external_id AS d_link_trans_dacct,
		dlinkcacct.external_id AS d_link_trans_cacct,
		clinkactr.center || 'acc' || clinkactr.id || 'tr' || clinkactr.subid AS c_link_fin_trans_id,
		clinkdacct.external_id AS c_link_trans_dacct,
		clinkcacct.external_id AS c_link_trans_cacct


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

LEFT JOIN account_trans dlinkactr
		ON dlinkactr.center = actr.debit_transaction_center
		AND dlinkactr.id = actr.debit_transaction_id
		AND dlinkactr.subid = actr.debit_transaction_subid

LEFT JOIN Accounts dlinkdacct
		ON dlinkdacct.center = dlinkactr.debit_accountcenter
		AND dlinkdacct.id = dlinkactr.debit_accountid

LEFT JOIN Accounts dlinkcacct
		ON dlinkcacct.center = dlinkactr.credit_accountcenter
		AND dlinkcacct.id = dlinkactr.credit_accountid

LEFT JOIN Account_Trans clinkactr
		ON actr.center || 'acc' || actr.id || 'tr' || actr.subid =
		clinkactr.debit_transaction_center || 'acc' || clinkactr.debit_transaction_id || 'tr' || clinkactr.debit_transaction_subid

LEFT JOIN Accounts clinkdacct
		ON clinkdacct.center = clinkactr.debit_accountcenter
		AND clinkdacct.id = clinkactr.debit_accountid

LEFT JOIN Accounts clinkcacct
		ON clinkcacct.center = clinkactr.credit_accountcenter
		AND clinkcacct.id = clinkactr.credit_accountid

WHERE
        agt.book_date >= :date_from
        AND agt.book_date <= :date_to
        AND actr.info_type = 11
        AND ((agt.debit_account_external_id in ('99995-000','0990-99995-000'))
        OR  (agt.credit_account_external_id in ('99995-000','0990-99995-000')))
		AND (dlinkdacct.external_id IS NULL OR dlinkdacct.external_id = dlinkcacct.external_id)
		AND (clinkdacct.external_id IS NULL OR clinkdacct.external_id = clinkcacct.external_id)

ORDER BY 
        actr.entry_time