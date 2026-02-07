-- This is the version from 2026-02-05
--  
SELECT
         p.external_id AS ExternalId,
		 p.center||'p'||p.id AS PersonID,
         (CASE pag.state 
                WHEN 1 THEN 'Created' 
                WHEN 2 THEN 'Sent' 
                WHEN 3 THEN 'Failed' 
                WHEN 4 THEN 'OK' 
                WHEN 5 THEN 'Ended, bank' 
                WHEN 6 THEN 'Ended, clearing house' 
                WHEN 7 THEN 'Ended, debtor'
                WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' 
                WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' 
                WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' 
                WHEN 17 THEN 'Signature missing' 
                ELSE 'UNDEFINED'        
         END) AS PaymentAgreementState,
         pag.ref AS PaymentAgreementReferenceId,
         ch.name AS PaymentAgreementType,
         pag.bank_account_holder as "Account holder name",
         pag.bank_regno AS "BSB",
         pag.bank_accno,
         longtodatec(pag.creation_time,pag.center)
         
FROM persons p
JOIN account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
JOIN clearinghouses ch ON pag.clearinghouse = ch.id
WHERE
        p.center IN (:Scope)
        AND 
        p.sex NOT IN ('C')
        AND 
        pag.clearinghouse in (202)
        AND
        pag.state = 4
        AND 
        pag.bank_account_holder ~ '^[0-9]+$'