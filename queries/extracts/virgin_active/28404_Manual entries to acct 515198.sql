SELECT 
        agt.amount,
        act.info as memberid,
        act.text, 
        act.aggregated_transaction_center, 
        act.aggregated_transaction_id, 
        agt.debit_account_external_id, 
        agt.credit_account_external_id,
        longtodateTZ(act.trans_time, 'Europe/London') TransTime,
	longtodateTZ(act.entry_time, 'Europe/London') EntryTime
FROM 
        account_trans act
JOIN 
        aggregated_transactions agt 
        ON act.aggregated_transaction_center = agt.center 
        AND act.aggregated_transaction_id = agt.id
LEFT JOIN 
        account_trans dact 
        ON dact.center = act.debit_transaction_center 
        AND dact.id = act.debit_transaction_id 
        AND dact.subid = act.debit_transaction_subid
LEFT JOIN
        account_trans mact 
        ON act.center = mact.debit_transaction_center 
        AND act.id = mact.debit_transaction_id 
        AND act.subid = mact.debit_transaction_subid
WHERE 
		agt.book_date >= :date_from
        AND agt.book_date <= :date_to
        AND ((agt.debit_account_external_id in ('515198'))
        OR (agt.credit_account_external_id in ('515198')))
        AND (dact.center is null and mact.center is null)
ORDER BY 
        act.entry_time