SELECT
    s.center||'ss'||s.id AS subscription,
    s.start_date,
    s.billed_until_date,
    s.owner_center||'p'||s.owner_id       AS subscription_owner,
    ar.customercenter||'p'||ar.customerid AS payment_agreement_owner
    --,*
FROM
    subscriptions s
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    s.payment_agreement_center = ar.center
AND s.payment_agreement_id = ar.id
LEFT JOIN
    relatives r
ON
    s.owner_center = r.relativecenter
AND s.owner_id = r.relativeid
AND ar.customercenter = r.center
AND ar.customerid = r.id
AND r.rtype = 12 --EFT Payer
WHERE
    r.center IS NULL
AND ar.customercenter IS NOT NULL
AND s.payment_agreement_center IS NOT NULL
AND s.owner_id <> ar.customerid
AND s.end_date IS NULL
AND s.start_date >= DATE 'today' -30