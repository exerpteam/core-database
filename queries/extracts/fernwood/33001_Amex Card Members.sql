SELECT DISTINCT
    p.external_id,
    p.center || 'p' || p.id AS PersonID,
    c.shortname AS "Centre",
    p.firstname || ' ' || p.lastname AS full_name,
    CASE pag.credit_card_type
        WHEN 5 THEN 'AmericanExpress'
        WHEN 109 THEN 'amex_applepay'
        ELSE 'Other'
    END AS "Card type"
FROM
    payment_requests pr
JOIN
    account_receivables ar
    ON ar.center = pr.center
    AND ar.id = pr.id
JOIN
    payment_agreements pag
    ON pr.agr_subid = pag.subid
    AND pr.center = pag.center
    AND pag.id = pr.id
JOIN
    persons p
    ON p.center = ar.customercenter
    AND p.id = ar.customerid
JOIN
    centers c
    ON c.id = p.center
WHERE
    pr.center IN (:Scope)
    AND pr.clearinghouse_id = 2
    AND p.sex != 'C'
    AND pag.state = 4
    AND pag.credit_card_type IN (5, 109)  -- Only Amex cards
