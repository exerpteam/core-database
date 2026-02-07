-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-10533
SELECT
    p.center||'p'||p.id                               AS "Member ID"
    , p.external_id                                   AS "External ID"
    , ar.balance                                      AS "Balance"
    , COALESCE(legacyPersonId.txtvalue,p.external_id) AS "GUID ID (External ID)"
    , email.txtvalue                                  AS "Email address"
    , p.fullname                                      AS "Payer name"
    , c.name                                          AS "Center"
    , gmp.fullname                                    AS "General Manager of the center"
    , c.email                                         AS "Email address of the center"
    , STRING_AGG (pr.name, ',')                       AS "Subscription name(s)"
    , SUM(s.subscription_price)                       AS "Sum of Subscription price"
    , SUM(abs(s.subscription_price)) = SUM(abs(ar.balance)) AS "Compare subscription price and balance (TRUE/FALSE)"
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
    spp_invoicelines_link sppl
ON
    sppl.invoiceline_center = art.ref_center
AND sppl.invoiceline_id = art.ref_id
AND art.ref_type = 'INVOICE'
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
AND pg.name = 'Annual'
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
    art.due_date <= current_date  
AND art.status != 'CLOSED'
AND ar.center in ($$scope$$)
AND s.state in (2,4,8) 
AND s.sub_state not in (8, 9) -- cancelled, blocked

GROUP BY
    p.center, p.external_id, p.id, ar.balance, 
    legacyPersonId.txtvalue, email.txtvalue, p.fullname,
    c.name, gmp.fullname, c.email 
