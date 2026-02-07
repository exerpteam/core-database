WITH
    params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                      AS center,
            datetolongc($$from_date$$::DATE::VARCHAR,c.id)                  AS from_date_long ,
            datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long,
            $$from_date$$::DATE                                             AS from_date,
            $$to_date$$::DATE                                             AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    p.external_id                              AS "Member Number" ,
    invl.productcenter||'prod'||invl.productid AS "Item to Pay ID",
    NULL                                       AS "Payment Subtype Code",
    longtodatec(inv.entry_time,inv.center)::DATE "Action Date",
    NULL              AS "Collection Method",
    invl.total_amount AS "Charge Amount",
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END "Member Status",
    CASE
        WHEN ccc.id IS NOT NULL
        THEN 'Arrears'
        ELSE 'OK'
    END "Payment Status",
    NULL              AS "Cancelation Date",
    c.name            AS "Club" ,
    c.id              AS "Club ID",
    ar.balance        AS "Account Balance",
    NULL              AS "Credit Balance",
    pr.name           AS "Plan Name",
    vat.orig_rate*100 AS "Tax Identity"
FROM
    evolutionwellness.persons p
JOIN
    evolutionwellness.invoices inv
ON
    inv.payer_center = p.center
AND inv.payer_id = p.id
JOIN
    evolutionwellness.invoice_lines_mt invl
ON
    inv.center = invl.center
AND inv.id = invl.id
AND invl.reason = 9
JOIN
    evolutionwellness.ar_trans art
ON
    art.ref_center = inv.center
AND art.ref_id = inv.id
AND art.ref_type = 'INVOICE'
JOIN
    evolutionwellness.centers c
ON
    c.id = p.center
JOIN
    params
ON
    params.center = c.id
JOIN
    evolutionwellness.products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
LEFT JOIN
    evolutionwellness.cashcollectioncases ccc
ON
    ccc.personcenter = p.center
AND ccc.personid = p.id
AND ccc.missingpayment
AND NOT ccc.closed
LEFT JOIN
    (
        SELECT
            ar.customercenter ,
            ar.customerid ,
            SUM(balance) AS balance
        FROM
            evolutionwellness.account_receivables ar
        GROUP BY
            ar.customercenter ,
            ar.customerid) ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
LEFT JOIN
    evolutionwellness.invoicelines_vat_at_link vat
ON
    vat.invoiceline_center = invl.center
AND vat.invoiceline_id = invl.id
AND vat.invoiceline_subid = invl.subid
WHERE
    art.due_date BETWEEN params.from_date AND params.to_date
AND p.sex != 'C'
AND pr.ptype = 10 -- addons