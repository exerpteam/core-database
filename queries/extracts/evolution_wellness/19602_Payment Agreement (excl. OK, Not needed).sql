SELECT
         p.center||'p'||p.id AS PersonId,
	 p.EXTERNAL_ID AS External_Id,	
	 (CASE P.PERSONTYPE
		WHEN 0 THEN 'PRIVATE' 
		WHEN 1 THEN 'STUDENT'
		WHEN 2 THEN 'STAFF'
		WHEN 3 THEN 'FRIEND'
		WHEN 4 THEN 'CORPORATE'
		WHEN 5 THEN 'ONE MAN CORPORATE'
		WHEN 6 THEN 'FAMILY'
		WHEN 7 THEN 'SENIOR'
		WHEN 8 THEN 'GUEST'
		ELSE 'UNKNOWN' END) AS PersonType,
	 (CASE P.STATUS
		WHEN 0 THEN 'LEAD'
		WHEN 1 THEN 'ACTIVE'
		WHEN 2 THEN 'INACTIVE'
		WHEN 3 THEN 'TEMPORARY INACTIVE'
		WHEN 4 THEN 'TRANSFERRED'
		WHEN 5 THEN 'DUPLICATE' 
      		WHEN 6 THEN 'PROSPECT'
		WHEN 7 THEN 'DELETED'
		WHEN 8 THEN 'ANONIMIZED'
		WHEN 9 THEN 'CONTACT' 
		ELSE 'UNKNOWN' END) AS PersonStatus,
     (CASE pag.state 
        WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' 
        WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor'
        WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' 
        WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' 
        WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' 
        WHEN 17 THEN 'Signature missing' 
        ELSE 'UNDEFINED' END) AS PaymentAgreementState,
     longtodatec(pag.creation_time,pag.center) as PaymentAgreement_Creationdate
FROM evolutionwellness.persons p
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
JOIN evolutionwellness.clearinghouses ch ON pag.clearinghouse = ch.id
WHERE
	p.sex NOT IN ('C')
	AND pag.state not in (4,13)
    AND pag.active IS TRUE
	AND p.status not in (2,5,7,8)
--	AND p.center between 100 and 199
	AND p.center IN (:Scope)