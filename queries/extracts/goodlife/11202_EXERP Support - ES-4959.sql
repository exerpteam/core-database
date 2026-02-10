-- The extract is extracted from Exerp on 2026-02-08
-- Find memberships that are linked to blocked other_payers
SELECT DISTINCT
    s.center||'ss'||s.id AS SUBSCRIPTION_ID,
    CASE
        WHEN s.state= 2
        THEN 'ACTIVE'
        WHEN s.state = 3
        THEN 'ENDED'
        WHEN s.state = 4
        THEN 'FROZEN'
        WHEN s.state = 7
        THEN 'WINDOW'
        WHEN s.state = 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END                             AS SUBSCRIPTION_STATE,
    s.owner_center||'p'||s.owner_id AS SUBSCRIPTION_OWNER_ID,
    CASE
        WHEN p2.persontype = 0
        THEN 'PRIVATE'
        WHEN p2.persontype = 1
        THEN 'STUDENT'
        WHEN p2.persontype = 2
        THEN 'STAFF'
        WHEN p2.persontype = 3
        THEN 'FRIEND'
        WHEN p2.persontype =4
        THEN 'CORPORATE'
        WHEN p2.persontype = 5
        THEN 'ONE MAN CORP'
        WHEN p2.persontype = 6
        THEN 'FAMILY'
        WHEN p2.persontype = 7
        THEN 'SENIOR'
        WHEN p2.persontype = 8
        THEN 'GUEST'
    END AS OWNER_TYPE,
    CASE
        WHEN p2.status = 0
        THEN 'LEAD'
        WHEN p2.status = 1
        THEN 'ACTIVE'
        WHEN p2.status = 2
        THEN 'INACTIVE'
        WHEN p2.status = 3
        THEN 'TEMP INACTIVE'
        WHEN p2.status = 4
        THEN 'TRANSFERRED'
        WHEN p2.status = 5
        THEN 'DUPLICATE'
        WHEN p2.status = 6
        THEN 'PROSPECT'
        WHEN p2.status = 7
        THEN 'DELETED'
        WHEN p2.status = 8
        THEN 'ANONYMIZED'
        WHEN p2.status = 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS OWNER_STATE,
    --s.sub_comment,
    CASE
        WHEN pag2.state = 1
        THEN 'CREATED'
        WHEN pag2.state = 2
        THEN 'SENT'
        WHEN pag2.state = 3
        THEN 'FAILED'
        WHEN pag2.state = 4
        THEN 'OK'
        WHEN pag2.state = 5
        THEN 'ENDED, BANK'
        WHEN pag2.state = 6
        THEN 'ENDED, CLEARINGHOUSE'
        WHEN pag2.state = 7
        THEN 'ENDED DEBTOR'
        WHEN pag2.state = 8
        THEN 'CANCELLED'
        WHEN pag2.state = 9
        THEN 'CANCELLED SENT'
        WHEN pag2.state = 10
        THEN 'ENDED, CREDITOR'
        WHEN pag2.state = 13
        THEN 'AGREEMENT NOT NEEDED'
        WHEN pag2.state = 14
        THEN 'INCOMPLETE'
        WHEN pag2.state = 15
        THEN 'TRANSFER'
        WHEN pag2.state = 16
        THEN 'RECREATED'
        WHEN pag2.state = 17
        THEN 'SIGNATURE MISSING'
        ELSE 'NO AGREEMENT'
    END                                                AS OWNER_AGREEMENT_STATE,
    p.current_person_center ||'p'||p.current_person_id AS LINKED_OTHER_PAYER_ID
FROM
    goodlife.subscriptions s
JOIN
    goodlife.subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
    AND s.subscriptiontype_id = st.id
JOIN
    goodlife.payment_agreements pag
ON
    pag.center = s.payment_agreement_center
    AND pag.id = s.payment_agreement_id
    AND pag.subid = s.payment_agreement_subid
JOIN
    goodlife.payment_accounts pa
ON
    pa.active_agr_center = s.payment_agreement_center
    AND pa.active_agr_id = s.payment_agreement_id
JOIN
    goodlife.account_receivables ar
ON
    ar.center = pa.center
    AND ar.id = pa.id
JOIN
    goodlife.relatives r
ON
    r.relativecenter = s.owner_center
    AND r.relativeid = s.owner_id
    AND r.rtype = 12
    AND r.status = 3
JOIN
    goodlife.persons p
ON
    p.center = r.center
    AND p.id = r.id
JOIN
    goodlife.account_receivables ar2
ON
    ar2.customercenter = s.owner_center
    AND ar2.customerid = s.owner_id
    AND ar2.ar_type = 4
LEFT JOIN
    goodlife.payment_accounts pa2
ON
    pa2.center = ar2.center
    AND pa2.id = ar2.id
LEFT JOIN
    goodlife.payment_agreements pag2
ON
    pag2.center = pa2.active_agr_center
    AND pag2.id = pa2.active_agr_id
    AND pag2.subid = pa2.active_agr_subid
JOIN
    goodlife.persons p2
ON
    p2.center = s.owner_center
    AND p2.id = s.owner_id
WHERE
    s.owner_center||'p'||s.owner_id <> ar.customercenter||'p'||ar.customerid
    AND ar.customercenter = r.center
    AND ar.customerid = r.id
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            goodlife.relatives r2
        WHERE
            r2.center = p.current_person_center
            AND r2.id = p.current_person_id
            AND r2.rtype = 12
            AND r2.status < 3)