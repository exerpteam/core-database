SELECT
        CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS STATE,
        ch.name,
        pr.globalid,
        pag.individual_deduction_day,
        count(*)
FROM puregym_switzerland.persons p
JOIN puregym_switzerland.account_receivables ar ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN puregym_switzerland.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
JOIN puregym_switzerland.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid
JOIN puregym_switzerland.clearinghouses ch ON pag.clearinghouse = ch.id
JOIN puregym_switzerland.subscriptions s ON p.center = s.owner_center AND p.id = s.owner_id
JOIN puregym_switzerland.products pr ON s.subscriptiontype_center = pr.center AND s.subscriptiontype_id = pr.id
WHERE  
        p.status IN (1,3)
        AND s.state IN (2,4,8)
GROUP BY
        pag.STATE,
        ch.name,
        pr.globalid,
        pag.individual_deduction_day
ORDER BY 4