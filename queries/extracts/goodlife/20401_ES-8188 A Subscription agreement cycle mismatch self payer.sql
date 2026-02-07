SELECT
    s.owner_center ||'p'|| s.owner_id AS member,
    s.start_date,
    TO_CHAR(longtodateC(s.creation_time, 990),'YYYY-MM-DD') AS creationtime,
    s.billed_until_date,
    s.center ||'ss'|| s.id AS SubscriptionID,
    pr.name ,
    pag.center || 'ar' || pag.id || 'agr' || pag.subid AS "Resolved_PaymentAgreementId",
    TO_CHAR(longtodateC(pag.creation_time, 990),'YYYY-MM-DD')                AS pag_creation_time ,
    s.payment_agreement_center ||'ar'|| s.payment_agreement_id || 'agr' ||
    s.payment_agreement_subid AS subscription_agreement_link,
    pag.ref                   AS agreement_ref
FROM
    subscriptions s
LEFT JOIN
    account_receivables ar
ON
    s.owner_center = ar.customercenter
AND s.owner_id = ar.customerid
AND ar.ar_type = 4
LEFT JOIN
    payment_accounts pa
ON
    ar.center = pa.center
AND ar.id = pa.id
LEFT JOIN
    relatives r
ON
    s.owner_center = r.relativecenter
AND s.owner_id = r.relativeid
AND r.status = 1
AND r.rtype = 12
LEFT JOIN
    state_change_log scl
ON
    scl.center = r.center
AND scl.id = r.id
AND scl.subid = r.subid
AND scl.entry_type = 4
AND scl.stateid = r.status
AND scl.entry_end_time IS NULL
LEFT JOIN
    account_receivables r_ar
ON
    r.center = r_ar.customercenter
AND r.id = r_ar.customerid
AND r_ar.ar_type = 4
LEFT JOIN
    payment_accounts r_pa
ON
    r_ar.center = r_pa.center
AND r_ar.id = r_pa.id
JOIN
    payment_agreements pag
ON
    (
        -- the subscription is linked to a specific agreement
        (
            s.payment_agreement_center IS NOT NULL
        AND s.payment_agreement_center = pag.center
        AND s.payment_agreement_id = pag.id
        AND s.payment_agreement_subid = pag.subid)
    OR
        -- the subscription is not linked to any agreement and the member does not have another
        -- payer
        (
            r.center IS NULL
        AND s.payment_agreement_center IS NULL
        AND ar.center = pag.center
        AND ar.id = pag.id
        AND pag.subid = pa.active_agr_subid) )
JOIN
    payment_cycle_config cyc
ON
    cyc.id = pag.payment_cycle_config_id
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    products pr
ON
    st.center = pr.center
AND st.id = pr.id
WHERE
    s.state IN (2,4,8)
AND (
        s.end_date IS NULL
    OR  s.billed_until_date IS NULL
    OR  s.billed_until_date < s.end_date)
AND st.st_type IN (1,2)
AND pr.globalid NOT IN ('PAP_M_ALL_CLUB_KAFP',
                        'SUBTENANT_RENTAL_PAP',
                        'SUBTENANT_RENTAL_ANNUAL_PAP')
AND (
        st.periodunit != cyc.interval_type)
AND r.center IS NULL 