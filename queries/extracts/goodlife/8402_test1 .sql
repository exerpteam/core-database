SELECT 
        art.amount,
        act.info as memberid,
        act.text, 
        act.aggregated_transaction_center, 
        act.aggregated_transaction_id, 
        agt.debit_account_external_id, 
        agt.credit_account_external_id,
        art.employeecenter || 'emp'  ||  art.employeeid as employeeID,
        p.firstname || ' ' || p.lastname As EmployeeName,
e.*,
		longtodateTZ(act.trans_time, 'America/Toronto') TransTime,
        longtodateTZ(act.entry_time, 'America/Toronto') EntryTime
FROM 
        account_trans act
JOIN 
        aggregated_transactions agt 
        ON act.aggregated_transaction_center = agt.center 
        AND act.aggregated_transaction_id = agt.id
LEFT JOIN 
        ar_trans art 
        ON art.ref_center = act.center 
        AND art.ref_id = act.id 
        AND art.ref_subid = act.subid 
        AND art.ref_type = 'ACCOUNT_TRANS'

join Employees e
		on e.center = art.employeecenter
		and e.id = art.employeeid

join Persons p
		on p.center = e.personcenter
		and p.id = e.personid

WHERE
        agt.book_date >= :date_from
        AND agt.book_date <= :date_to
        AND act.info_type = 11
        AND ((agt.debit_account_external_id in ('99995-000','0990-99995-000'))
        OR  (agt.credit_account_external_id in ('99995-000','0990-99995-000')))
ORDER BY 
        act.entry_time