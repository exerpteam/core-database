SELECT
    sm.person_id,
    sm.member_id,
    sm.subscription_price,
    sc.new_subscription_center ||'ss'|| sc.new_subscription_id AS new_sub_id,
    sp.price                                                   AS new_price,
    sp.from_date                                               AS from_date,
    agr.creditor_id                                            AS payment_cycle
FROM
    public.ec10547_subscription_migration sm
JOIN
    subscriptions s
ON
    s.center ||'ss'|| s.id = sm.subscription_id
JOIN
    sats.subscription_price sp
ON
    sp.subscription_center = s.center
AND sp.subscription_id = s.id
JOIN
    sats.subscription_change sc
ON
    sc.old_subscription_center = s.center
AND sc.old_subscription_id = s.id
LEFT JOIN
    (   SELECT
            ar.customercenter,
            ar.customerid,
            pag.creditor_id
        FROM
            sats.account_receivables ar
        JOIN
            sats.payment_accounts pa
        ON
            pa.center = ar.center
        AND pa.id = ar.id
        AND ar.ar_type = 4
        JOIN
            sats.payment_agreements pag
        ON
            pag.center = pa.active_agr_center
        AND pag.id = pa.active_agr_id
        AND pag.subid = pa.active_agr_subid) agr
ON
    agr.customercenter = s.owner_center
AND agr.customerid = s.owner_id
WHERE
    sp.from_date >= '2025-12-01'
AND sp.cancelled = false
AND sc.new_subscription_center IS NOT NULL
AND sc.employee_center = 100
AND sc.employee_id = 94298