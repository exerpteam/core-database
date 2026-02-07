 WITH LIST_CENTERS AS materialized
 (
     SELECT
         c.ID AS CENTERID,
         CAST($$OpeningDate$$ AS DATE) AS OpeningDate
     FROM CENTERS c
     WHERE
         CAST(c.ID AS VARCHAR) IN ($$Scope$$)
)
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
     sfp.start_date                                              AS "Start date freeze period",
     sfp.end_date                                                AS "End date freeze perod",
     sfp.text                                                    AS "Freeze reason",
     s.billed_until_date                                         AS "Billed until date",
     pag.individual_deduction_day                                AS "Deduction day",
     --floor((row_number() over(order by sfp.subscription_center))/400)+1 AS threadnumber,
     sfp.subscription_center,
     sfp.subscription_id,
     sfp.id,
     lc.OpeningDate-1 AS NewFreezeEndDate
 FROM
     persons p
 JOIN LIST_CENTERS lc ON p.CENTER = lc.CENTERID
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
     SUBSCRIPTION_FREEZE_PERIOD sfp
 ON
     sfp.subscription_center = s.center
     AND sfp.subscription_id = s.id
     AND sfp.state = 'ACTIVE'
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
 WHERE
         sfp.END_DATE >= lc.OpeningDate
