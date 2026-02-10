-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS person_id,
        (CASE p.status
                WHEN 1 THEN 'ACTIVE'
                WHEN 3 THEN 'TEMPORARY INACTIVE'
        END) person_status,
        CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS STATE,
        ch.name,
        pag.individual_deduction_day
FROM puregym_switzerland.persons p
JOIN puregym_switzerland.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN puregym_switzerland.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN puregym_switzerland.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN puregym_switzerland.clearinghouses ch ON pag.clearinghouse = ch.id
WHERE  
        p.status IN (1,3)
        AND 
        (
                ch.id = 201 AND pag.state IN (4)
                OR
                ch.id = 1 AND pag.state IN (13)
        )