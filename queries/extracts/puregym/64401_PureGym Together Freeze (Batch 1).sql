SELECT
    c.id                                                        AS CenterId,
    c.shortname                                                 AS CenterName,
    p.center || 'p' || p.id                                     AS MembershipNumber,
    p.external_id                                               AS MemberExternalId,
    s.center || 'ss' || s.id                                    AS SubscriptionId,
    prod.name                                                   AS SubscriptionName,
    s.start_date                                                AS SubscriptionStartDate,
    s.end_date                                                  AS SubscriptionEndDate,
    DECODE(st.ST_TYPE,0,'Cash',1,'EFT',2,'Clipcard',3,'Course') AS SubscriptionType,
    srd.start_date                                              AS "Start date freeze period",
    srd.end_date                                                AS "End date freeze perod",
    srd.text                                                    AS "Freeze reason",
    s.billed_until_date                                         AS "Billed until date",
    pag.individual_deduction_day                                AS "Deduction day",
    pehome.txtvalue                                             AS PGT
FROM
    persons p
JOIN
    centers c
ON
    c.id = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
ON
    prod.center = st.center
    AND prod.id = st.id
JOIN
    subscription_reduced_period srd
ON
    srd.subscription_center = s.center
    AND srd.subscription_id = s.id
    AND srd.state = 'ACTIVE'
    AND srd.type = 'FREEZE'
    AND srd.text = 'PureGym Together'
LEFT JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
    AND ar.customerid = p.id
    AND ar.ar_type = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pa
ON
    pa.center = ar.center
    AND pa.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pa.ACTIVE_AGR_center
    AND pag.ID = pa.ACTIVE_AGR_id
    AND pag.SUBID = pa.ACTIVE_AGR_SUBID
LEFT JOIN
    person_ext_attrs pehome
ON
    pehome.personcenter = p.center
    AND pehome.personid = p.id
    AND pehome.name = 'PUREGYMATHOME'
WHERE
    p.center IN ($$Scope$$)