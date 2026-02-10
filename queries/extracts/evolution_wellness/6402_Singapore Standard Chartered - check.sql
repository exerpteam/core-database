-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
         p.external_id 
,p.center||'p'||p.id AS PersonId,
         (CASE pag.state 
                WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' 
                WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor'
                WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' 
                WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' 
                WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' 
                WHEN 17 THEN 'Signature missing' 
                ELSE 'UNDEFINED'        
         END) AS PaymentAgreementState,
         pag.ref AS PaymentAgreementReferenceId,
         ch.name AS PaymentAgreementType,
         'Paid' AS "Issue"
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
JOIN evolutionwellness.clearinghouses ch ON pag.clearinghouse = ch.id
JOIN evolutionwellness.payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND pag.clearinghouse = 1001     
        AND pag.state = 4
        AND pr.state = 1
        AND ar.balance = 0
UNION ALL
SELECT
         p.external_id ,p.center||'p'||p.id AS PersonId,
         (CASE pag.state 
                WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' 
                WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor'
                WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' 
                WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' 
                WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' 
                WHEN 17 THEN 'Signature missing' 
                ELSE 'UNDEFINED'        
         END) AS PaymentAgreementState,
         pag.ref AS PaymentAgreementReferenceId,
         ch.name AS PaymentAgreementType,
         'No Bank details' AS "Issue"
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN evolutionwellness.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid AND ar.ar_type = 4
JOIN evolutionwellness.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN evolutionwellness.payment_agreements pag ON pac.center = pag.center AND pac.id = pag.id
JOIN evolutionwellness.clearinghouses ch ON pag.clearinghouse = ch.id
JOIN evolutionwellness.payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND pag.clearinghouse = 1001     
        AND pag.bank_regno IS NULL
        AND pag.state = 4
        AND pr.state = 1
        
