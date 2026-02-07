
SELECT * FROM (

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
        AND ((agt.debit_account_external_id in ('99995-000','0990-99995-000','0021-99995-000','0023-99995-000','0087-99995-000'))
        OR  (agt.credit_account_external_id in ('99995-000','0990-99995-000','0021-99995-000','0023-99995-000','0087-99995-000')))
		AND (dlinkdacct.external_id IS NULL OR RIGHT(dlinkdacct.external_id,9) = RIGHT(dlinkcacct.external_id,9))
		AND (clinkdacct.external_id IS NULL OR RIGHT(clinkdacct.external_id,9) = RIGHT(clinkcacct.external_id,9))

UNION

select 
		-inv1.net_amount AS amount,
		inv1.person_center||'p'||inv1.person_id as memberid,
        actr1.text, 
		'corp inv' AS type,
        actr1.aggregated_transaction_center || 'agt' || actr1.aggregated_transaction_id AS agtid,
		agt1.book_date AS AGT_Date,
		actr1.aggregated_transaction_center AS agt_center, 
        agt1.debit_account_external_id AS debit_account,
		dacct1.name AS debit_account_name, 
        agt1.credit_account_external_id AS credit_account,
		cacct1.name AS credit_account_name,
        art1.employeecenter || 'emp'  ||  art1.employeeid as employeeID,
        p1.firstname || ' ' || p1.lastname As EmployeeName,
		TO_CHAR(longtodateTZ(actr1.trans_time, 'America/Toronto'),'YYYY-MM-DD') TransTime,
        TO_CHAR(longtodateTZ(actr1.entry_time, 'America/Toronto'),'YYYY-MM-DD') EntryTime,
		actr1.center || 'acc' || actr1.id || 'tr' || actr1.subid AS fin_trans_id,
		actr1.debit_transaction_center || 'acc' || actr1.debit_transaction_id || 'tr' || actr1.debit_transaction_subid AS d_link_fin_trans_id,
		dlinkdacct1.external_id AS d_link_trans_dacct,
		dlinkcacct1.external_id AS d_link_trans_cacct,
		clinkactr1.center || 'acc' || clinkactr1.id || 'tr' || clinkactr1.subid AS c_link_fin_trans_id,
		clinkdacct1.external_id AS c_link_trans_dacct,
		clinkcacct1.external_id AS c_link_trans_cacct

from
account_trans actr1
JOIN 
        aggregated_transactions agt1 
        ON actr1.aggregated_transaction_center = agt1.center 
        AND actr1.aggregated_transaction_id = agt1.id

join invoice_lines_mt inv1
on actr1.center = inv1.account_trans_center
and actr1.id = inv1.account_trans_id
AND actr1.subid = inv1.account_trans_subid

join products prod1
on prod1.center = inv1.productcenter
and prod1.id = inv1.productid
and prod1.globalid = 'CORPORATE_REFUND_TO_MEMBER'

join ar_trans art1


	 on art1.ref_center = inv1.center 
       AND art1.ref_id = inv1.id 
	and art1.ref_type = 'INVOICE'

JOIN Employees e1
		ON e1.center = art1.employeecenter
		AND e1.id = art1.employeeid

JOIN Persons p1
		ON p1.center = e1.personcenter
		AND p1.id = e1.personid


JOIN Accounts dacct1
		ON dacct1.center = actr1.debit_accountcenter
		AND dacct1.id = actr1.debit_accountid

JOIN Accounts cacct1
		ON cacct1.center = actr1.credit_accountcenter
		AND cacct1.id = actr1.credit_accountid

LEFT JOIN account_trans dlinkactr1
		ON dlinkactr1.center = actr1.debit_transaction_center
		AND dlinkactr1.id = actr1.debit_transaction_id
		AND dlinkactr1.subid = actr1.debit_transaction_subid

LEFT JOIN Accounts dlinkdacct1
		ON dlinkdacct1.center = dlinkactr1.debit_accountcenter
		AND dlinkdacct1.id = dlinkactr1.debit_accountid

LEFT JOIN Accounts dlinkcacct1
		ON dlinkcacct1.center = dlinkactr1.credit_accountcenter
		AND dlinkcacct1.id = dlinkactr1.credit_accountid

LEFT JOIN Account_Trans clinkactr1
		ON actr1.center || 'acc' || actr1.id || 'tr' || actr1.subid =
		clinkactr1.debit_transaction_center || 'acc' || clinkactr1.debit_transaction_id || 'tr' || clinkactr1.debit_transaction_subid

LEFT JOIN Accounts clinkdacct1
		ON clinkdacct1.center = clinkactr1.debit_accountcenter
		AND clinkdacct1.id = clinkactr1.debit_accountid

LEFT JOIN Accounts clinkcacct1
		ON clinkcacct1.center = clinkactr1.credit_accountcenter
		AND clinkcacct1.id = clinkactr1.credit_accountid

WHERE
        agt1.book_date >= :date_from
        AND agt1.book_date <= :date_to

UNION

select
		cn2.net_amount AS amount,
		cn2.person_center||'p'||cn2.person_id as memberid,
        actr2.text, 
		'corp inv' AS type, 
        actr2.aggregated_transaction_center || 'agt' || actr2.aggregated_transaction_id AS agtid,
		agt2.book_date AS AGT_Date,
		actr2.aggregated_transaction_center AS agt_center, 
        agt2.debit_account_external_id AS debit_account,
		dacct2.name AS debit_account_name, 
        agt2.credit_account_external_id AS credit_account,
	    cacct2.name AS credit_account_name,
        art2.employeecenter || 'emp'  ||  art2.employeeid as employeeID,
        p2.firstname || ' ' || p2.lastname As EmployeeName,
		TO_CHAR(longtodateTZ(actr2.trans_time, 'America/Toronto'),'YYYY-MM-DD') TransTime,
        TO_CHAR(longtodateTZ(actr2.entry_time, 'America/Toronto'),'YYYY-MM-DD') EntryTime,
		actr2.center || 'acc' || actr2.id || 'tr' || actr2.subid AS fin_trans_id,
		actr2.debit_transaction_center || 'acc' || actr2.debit_transaction_id || 'tr' || actr2.debit_transaction_subid AS d_link_fin_trans_id,
		dlinkdacct2.external_id AS d_link_trans_dacct,
		dlinkcacct2.external_id AS d_link_trans_cacct,
		clinkactr2.center || 'acc' || clinkactr2.id || 'tr' || clinkactr2.subid AS c_link_fin_trans_id,
		clinkdacct2.external_id AS c_link_trans_dacct,
		clinkcacct2.external_id AS c_link_trans_cacct

from
account_trans actr2
JOIN 
        aggregated_transactions agt2
        ON actr2.aggregated_transaction_center = agt2.center 
        AND actr2.aggregated_transaction_id = agt2.id

join credit_note_lines_mt cn2
	on actr2.center = cn2.account_trans_center
	and actr2.id = cn2.account_trans_id
	AND actr2.subid = cn2.account_trans_subid

join products prod2
	on prod2.center = cn2.productcenter
	and prod2.id = cn2.productid
	and prod2.globalid = 'CORPORATE_REFUND_TO_MEMBER'

join ar_trans art2

	 on art2.ref_center = cn2.center 
       AND art2.ref_id = cn2.id 
	and art2.ref_type = 'CREDIT_NOTE'

JOIN Employees e2
		ON e2.center = art2.employeecenter
		AND e2.id = art2.employeeid

JOIN Persons p2
		ON p2.center = e2.personcenter
		AND p2.id = e2.personid

JOIN Accounts dacct2
		ON dacct2.center = actr2.debit_accountcenter
		AND dacct2.id = actr2.debit_accountid

JOIN Accounts cacct2
		ON cacct2.center = actr2.credit_accountcenter
		AND cacct2.id = actr2.credit_accountid

LEFT JOIN account_trans dlinkactr2
		ON dlinkactr2.center = actr2.debit_transaction_center
		AND dlinkactr2.id = actr2.debit_transaction_id
		AND dlinkactr2.subid = actr2.debit_transaction_subid

LEFT JOIN Accounts dlinkdacct2
		ON dlinkdacct2.center = dlinkactr2.debit_accountcenter
		AND dlinkdacct2.id = dlinkactr2.debit_accountid

LEFT JOIN Accounts dlinkcacct2
		ON dlinkcacct2.center = dlinkactr2.credit_accountcenter
		AND dlinkcacct2.id = dlinkactr2.credit_accountid

LEFT JOIN Account_Trans clinkactr2
		ON actr2.center || 'acc' || actr2.id || 'tr' || actr2.subid =
		clinkactr2.debit_transaction_center || 'acc' || clinkactr2.debit_transaction_id || 'tr' || clinkactr2.debit_transaction_subid

LEFT JOIN Accounts clinkdacct2
		ON clinkdacct2.center = clinkactr2.debit_accountcenter
		AND clinkdacct2.id = clinkactr2.debit_accountid

LEFT JOIN Accounts clinkcacct2
		ON clinkcacct2.center = clinkactr2.credit_accountcenter
		AND clinkcacct2.id = clinkactr2.credit_accountid

WHERE
        agt2.book_date >= :date_from
        AND agt2.book_date <= :date_to
) A

ORDER BY A.entrytime
