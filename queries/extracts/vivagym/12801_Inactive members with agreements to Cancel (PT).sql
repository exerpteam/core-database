-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
            CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END AS STATE,
            p.center || 'p' || p.id person_id,
           -- (CASE
             --   WHEN pag.clearinghouse = 1 THEN 'Adyen'
             --   WHEN pag.clearinghouse = 201 THEN 'SEPA'
             --   ELSE pag.clearinghouse::text
            -- END) 
ch.name AS clearinghouse,
CASE
WHEN p.status = 0 THEN 'Lead'
WHEN p.status = 2 THEN 'Inactive'
END AS person_status


FROM persons p
JOIN vivagym.centers c
        ON c.id = p.center
        AND c.country = 'PT'
JOIN vivagym.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4
JOIN vivagym.payment_accounts pac
        ON pac.center = ar.center
        AND pac.id = ar.id
JOIN vivagym.payment_agreements pag
        ON pac.active_agr_center = pag.center
        AND pac.active_agr_id = pag.id
        AND pac.active_agr_subid = pag.subid
JOIN vivagym.clearinghouses ch ON ch.id = pag.clearinghouse
WHERE
        p.status IN (0,2) -- only LEAD or INACTIVE members
        AND pag.state IN (1,2,4)
        AND NOT EXISTS --No subscription start in the future, e.g. presale clubs
        (
                SELECT
                        1
                FROM vivagym.subscriptions s
                WHERE
                        s.owner_center = p.center
                        AND s.owner_id= p.id
                        AND s.state IN (2,4,8)
        )
        -- EXCLUDE PAYERS  
        AND NOT EXISTS
        (
                SELECT
                        1
                FROM
                        vivagym.relatives r
                WHERE
                        r.center = p.center
                        AND r.id = p.id
                        AND r.rtype = 12
                        AND r.status < 2
        )
        ORDER BY 3,1