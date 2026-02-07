SELECT 
        p.center || 'p' || p.id AS "PersonID"
	,longtodatec(pa.creation_time,pa.center) AS "Creation Date"
	,pa.clearinghouse_ref AS "Payway Customer Number"
	,p.center || 'p' || p.id AS "PersonID"
    ,p.fullname AS "Person Full Name"
	,pa.ref AS "Payment Agreement Reference"
	,CASE pa.state
			WHEN 1 THEN 'CREATED'
			WHEN 2 THEN 'Sent'
			WHEN 3 THEN 'Failed'
			WHEN 4 THEN 'OK'
			WHEN 5 THEN 'Ended, bank'
			WHEN 6 THEN 'Ended, clearing house'
			WHEN 7 THEN 'Ended, debtor'
			WHEN 8 THEN 'Cancelled, not sent'
			WHEN 9 THEN 'Cancelled, sent'
			WHEN 10 THEN 'Ended, creditor'
			WHEN 11 THEN 'No agreement'
			WHEN 12 THEN 'Cash payment (deprecated)'
			WHEN 13 THEN 'Agreement not needed (invoice payment)'
			WHEN 14 THEN 'Agreement information incomplete'
			WHEN 15 THEN 'Transfer'
			WHEN 16 THEN 'Agreement Recreated'
			WHEN 17 THEN 'Signature missing'
                        ELSE 'UNDEFINED'
	END AS "Payment Agreement State"
FROM 
        fernwood.persons p
JOIN 
        fernwood.account_receivables ar 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid 
                AND ar.ar_type = 4
JOIN 
        fernwood.payment_agreements pa 
                ON ar.center = pa.center 
                AND ar.id = pa.id
WHERE 
        pa.clearinghouse_ref in (:PaywayCustomerID)
        AND pa.clearinghouse = 2