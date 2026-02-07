SELECT
    pr.center,
    pr.id,
    pr.subid,
    p.center || 'p' || p.id AS "PERSONKEY",
    pag.clearinghouse_ref   AS customer_id,
    p.fullname              AS customer_name,
    pea.txtvalue            AS customer_email,
    peam.txtvalue           AS customer_phone,
    pag.ref                 AS key,
    prs.open_amount         AS value,
    pr.full_reference       AS transaction_key,
    prs.ref                 AS descriptive
    
FROM
    payment_request_specifications prs
JOIN
    centers c
ON
    c.id = prs.center
AND c.country = 'PT'
JOIN
    account_receivables ar
ON
    ar.center = prs.center
AND ar.id = prs.id
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
JOIN
    payment_requests pr
ON
    prs.center = pr.inv_coll_center
AND prs.id = pr.inv_coll_id
AND prs.subid = pr.inv_coll_subid
AND pr.request_type = 1
AND pr.state NOT IN (1,2,3,4,8,18,19,20,22)
JOIN
    payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
JOIN
    payment_agreements pag
ON
    pag.center = pac.active_agr_center
AND pag.id = pac.active_agr_id
AND pag.subid = pac.active_agr_subid
LEFT JOIN
    person_ext_attrs pea
ON
    p.center = pea.personcenter
AND p.id = pea.personid
AND pea.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs peam
ON
    p.center = peam.personcenter
AND p.id = peam.personid
AND peam.name = '_eClub_PhoneSMS'
WHERE
    ar.balance < 0
AND ar.ar_type = 4
AND p.sex != 'C'
AND prs.open_amount > 0
AND pr.clearinghouse_id IN (2208,1603)
AND pr.center IN (:center)