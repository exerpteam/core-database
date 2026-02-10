-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center ||'p'|| p.id AS member_id,
    p.fullname,
    CASE ar.ar_type
        WHEN 4
        THEN 'Payment'
        WHEN 5
        THEN 'Debt'
    END                       AS Account_type,
    SUM(art.unsettled_amount) AS overdue_debt,
    --ar.balance,
    CASE t.STATE
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
        ELSE 'No Agreement'
    END AS agreement_state
FROM
    persons p
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type IN (4,5)
AND ar.balance < -19
JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
AND art.due_date < TO_DATE(getcentertime(p.center), 'YYYY-MM-DD')
AND art.status IN ('OPEN',
                   'NEW')
LEFT JOIN
    (
        SELECT
            pac.center,
            pac.id,
            pag.state
        FROM
            payment_accounts pac
        JOIN
            payment_agreements pag
        ON
            pag.center = pac.active_agr_center
        AND pag.id = pac.active_agr_id
        AND pag.subid = pac.active_agr_subid ) t
ON
    t.center = ar.center
AND t.id = ar.id
WHERE
    p.sex != 'C'
AND p.status IN (1,3)
AND (
        t.center IS NULL
    OR  t.state != 4)
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            persons op
        JOIN
            relatives r
        ON
            r.center = op.center
        AND r.id = op.id
        AND r.rtype = 12
        JOIN
            persons p2
        ON
            p2.center = r.relativecenter
        AND p2.id = r.relativeid
        AND r.status < 2
        JOIN
            account_receivables ar2
        ON
            ar2.customercenter = op.center
        AND ar2.customerid = op.id
        AND ar2.ar_type = 4
        JOIN
            payment_accounts pac2
        ON
            pac2.center = ar2.center
        AND pac2.id = ar2.id
        JOIN
            payment_agreements pag2
        ON
            pag2.center = pac2.active_agr_center
        AND pag2.id = pac2.active_agr_id
        AND pag2.subid = pac2.active_agr_subid
        WHERE
            p2.status IN (1,3)
        AND pag2.state = 4
        AND p2.center = p.center
        AND p2.id = p.id)
AND p.center IN (:scope)
GROUP BY
    p.center ||'p'|| p.id,
    p.fullname,
    ar.ar_type,
    t.STATE,
    ar.balance
ORDER BY
member_id