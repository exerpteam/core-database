-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center ||'p'|| p.id AS member_id,
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END                    AS PERSONTYPE,
    s.center ||'ss'|| s.id AS subscription_id,
    sp.price
    /*,
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
    ELSE 'No Agreement'
    END AS agreement_state */
FROM
    persons p
JOIN
    subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
AND s.state IN (2,4)
JOIN
    sats.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
AND st.st_type = 1
JOIN
    sats.subscription_price sp
ON
    sp.subscription_center = s.center
AND sp.subscription_id = s.id
AND sp.cancelled = false
AND sp.from_date <= TO_DATE(getcentertime(s.center), 'YYYY-MM-dd')
AND (
        sp.to_date IS NULL
    OR  sp.to_date >= TO_DATE(getcentertime(s.center), 'YYYY-MM-dd'))
JOIN
    sats.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    sats.payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
    /*LEFT JOIN
    sats.payment_agreements pag
    ON
    pag.center = pac.active_agr_center
    AND pag.id = pac.active_agr_id
    AND pag.subid = pac.active_agr_subid */
WHERE
    /* (
    pag.center IS NULL
    OR  pag.state != 4) */
    pac.active_agr_center IS NULL
AND p.status IN (1,3)
AND p.persontype NOT IN (4,5)
AND sp.price > 0
AND s.start_date >= '2022-01-01'
AND (
        s.billed_until_date < s.end_date
    OR  s.end_date IS NULL)
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
        /*JOIN
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
        AND pag2.subid = pac2.active_agr_subid */
        WHERE
            p2.status IN (1,3)
        --AND pag2.state = 4
        AND p2.center = p.center
        AND p2.id = p.id)
		AND p.center IN (:scope)
ORDER BY
    p.center,
    p.id