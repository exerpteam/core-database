 WITH
     LIST_CENTERS AS MATERIALIZED
     (
         SELECT
             c.ID AS CENTERID
         FROM
             CENTERS c
         WHERE
             CAST(c.ID AS VARCHAR) IN ($$Scope$$)
     )
 SELECT
     t1.SubscriptionId,
     sp.FROM_DATE,
     sp.TO_DATE,
     sp.PRICE,
     sp.TYPE
 FROM
     (
         SELECT
             c.id                                                        AS CenterId,
             c.shortname                                                 AS CenterName,
             p.center || 'p' || p.id                                     AS MembershipNumber,
             p.external_id                                               AS MemberExternalId,
             s.center || 'ss' || s.id                                    AS SubscriptionId,
             prod.name                                                   AS SubscriptionName,
             s.start_date                                                AS SubscriptionStartDate,
             s.end_date                                                  AS SubscriptionEndDate,
             CASE st.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'EFT' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS SubscriptionType,
             sf.start_date                                               AS "Start date freeze period",
             sf.end_date                                                 AS "End date freeze perod",
             sf.text                                                     AS "Freeze reason",
             s.billed_until_date                                         AS "Billed until date",
             pag.individual_deduction_day                                AS "Deduction day",
             pehome.txtvalue                                             AS PGT,
             CASE
                 WHEN cc.CENTER IS NOT NULL
                     OR cc_op.CENTER IS NOT NULL
                 THEN 'Yes'
                 ELSE 'No'
             END      AS "Debt case",
             s.center AS SubCenter,
             s.id     AS SubId
         FROM
             persons p
         JOIN
             LIST_CENTERS lc
         ON
             p.CENTER = lc.CENTERID
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
         LEFT JOIN
             SUBSCRIPTION_FREEZE_PERIOD sf
         ON
             sf.subscription_center = s.center
             AND sf.subscription_id = s.id
             AND sf.state = 'ACTIVE'
             AND sf.text = 'PureGym Together'
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
         LEFT JOIN
             CASHCOLLECTIONCASES cc
         ON
             cc.PERSONCENTER = p.CENTER
             AND cc.PERSONID = p.ID
             AND cc.MISSINGPAYMENT = 1
             AND cc.CLOSED = 0
             -- other payer
         LEFT JOIN
             RELATIVES r
         ON
             r.RELATIVECENTER = p.CENTER
             AND r.RELATIVEID = p.id
             AND r.RTYPE = 12
             AND r.status = 1
             -- other payer's debt case
         LEFT JOIN
             CASHCOLLECTIONCASES cc_op
         ON
             cc_op.PERSONCENTER = r.CENTER
             AND cc_op.PERSONID = r.ID
             AND cc_op.MISSINGPAYMENT = 1
             AND cc.CLOSED = 0
         WHERE
             s.STATE IN (2,4,8)
             AND ( (
                     $$product_group_selected$$ IN (6407,5602)
                     AND EXISTS
                     (
                         SELECT
                             1
                         FROM
                             PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                         WHERE
                             ppl.PRODUCT_CENTER = prod.CENTER
                             AND ppl.PRODUCT_ID = prod.ID
                             AND ppl.PRODUCT_GROUP_ID IN ($$product_group_selected$$)))
                 OR ((
                         $$product_group_selected$$ = 1
                         AND NOT EXISTS
                         (
                             SELECT
                                 1
                             FROM
                                 PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                             WHERE
                                 ppl.PRODUCT_CENTER = prod.CENTER
                                 AND ppl.PRODUCT_ID = prod.ID
                                 AND ppl.PRODUCT_GROUP_ID IN (6407,5602,
                                                              401)))) )
             AND (
                 sf.ID IS NOT NULL
                 OR (
                     sf.ID IS NULL
                     AND pehome.TXTVALUE = 'true' ) ) ) t1
 JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = t1.SubCenter
     AND sp.SUBSCRIPTION_ID = t1.SubId
 WHERE
     sp.FROM_DATE >= $$SubPriceDate$$
     AND sp.CANCELLED = 0
