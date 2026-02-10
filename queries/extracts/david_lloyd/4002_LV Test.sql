-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center||'p'||p.id                               AS "Member ID"
    , p.external_id                                   AS "External ID"
    , ar.balance                                      AS "Balance"
    , COALESCE(legacyPersonId.txtvalue,p.external_id) AS "GUID ID (External ID)"
    ,email.txtvalue                                   AS "Email address"
    , p.firstname                                     AS "First name"
    , p.lastname                                      AS "Last name"
    , c.name                                          AS "Center"
    , gmp.fullname                                    AS "General Manager of the center"
    , c.email                                            AS "Email address of the center"
    , pr.name                                            AS "Subscription name"
    , s.subscription_price AS "Subscription price"
    ,  abs(s.subscription_price) = abs(ar.balance)                                            AS
    "Compare subscription price and balance (TRUE/FALSE)"
FROM
    persons p
JOIN
    account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
JOIN
    ar_trans art
ON
    ar.center = art.center
AND ar.id = art.id
JOIN
    payment_request_specifications prs
ON
    prs.center = art.payreq_spec_center
AND prs.id = art.payreq_spec_id
AND prs.subid = art.payreq_spec_subid
JOIN
    spp_invoicelines_link sppl
ON
    sppl.invoiceline_center = art.ref_center
AND sppl.invoiceline_id = art.ref_id
--AND art.ref_type = 'INVOICE'
JOIN
    subscriptions s
ON
    s.center = sppl.period_center
AND s.id = sppl.period_id
JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
JOIN
    product_and_product_group_link ppgl
ON
    ppgl.product_center = pr.center
AND ppgl.product_id = pr.id
JOIN
    product_group pg
ON
    pg.id = ppgl.product_group_id
--AND pg.name = 'Annual'
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center =email.PERSONCENTER
AND p.id =email.PERSONID
AND email.name='_eClub_Email'
JOIN
    centers c
ON
    c.id = p.center
LEFT JOIN 
    persons gmp 
ON 
    gmp.center = c.manager_center 
AND gmp.id= c.manager_id
WHERE
    art.due_date <= current_date  and
    art.status != 'CLOSED'
and ar.center in ($$scope$$)