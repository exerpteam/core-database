-- This is the version from 2026-02-05
--  
SELECT
    p.external_id,
    CASE pag.STATE 
        WHEN 1 
        THEN 'Created' 
        WHEN 2 
        THEN 'Sent' 
        WHEN 3 
        THEN 'Failed' 
        WHEN 4 
        THEN 'OK' 
        WHEN 5 
        THEN 'Ended, bank' 
        WHEN 6 
        THEN 'Ended, clearing house' 
        WHEN 7 
        THEN 'Ended, debtor' 
        WHEN 8 
        THEN 'Cancelled, not sent' 
        WHEN 9 
        THEN 'Cancelled, sent' 
        WHEN 10 
        THEN 'Ended, creditor' 
        WHEN 11 
        THEN 'No agreement' 
        WHEN 12 
        THEN 'Cash payment (deprecated)' 
        WHEN 13 
        THEN 'Agreement not needed (invoice payment)' 
        WHEN 14 
        THEN 'Agreement information incomplete' 
        WHEN 15 
        THEN 'Transfer' 
        WHEN 16 
        THEN 'Agreement Recreated' 
        WHEN 17 
        THEN 'Signature missing' 
        ELSE 'UNDEFINED' 
    END AS agreement_state
FROM
    persons p
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    payment_agreements pag
ON
    pag.center = ar.center
AND pag.id = ar.id
WHERE
pag.center IN (:scope)