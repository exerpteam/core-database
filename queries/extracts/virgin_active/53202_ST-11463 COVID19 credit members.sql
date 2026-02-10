-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             c.id                               AS center_id,
             $$FromDate$$ AS from_date,
             $$ToDate$$ AS to_date
         FROM
             CENTERS c
         WHERE
             c.id IN ($$scope$$)
     )
 SELECT
     x.*,
     ROUND((INV_TOTAL_AMOUNT / inv_days) * covid_credit_days,2) AS credit_amount
 FROM
     (
         SELECT
             s.OWNER_CENTER||'p'||    s.owner_id,
             srp.start_date        AS SRP_START,
             srp.end_date          AS SRP_END,
             s.billed_until_date,
             srp.text AS SRP_TEXT,
             CASE
                 WHEN srp.TEXT LIKE '%COVID%'
                 THEN 1
                 ELSE 0
             END                                                 AS IS_COVID,
             sfp.TYPE                                              AS FREEZE_TYPE,
             spp.from_date                                              INV_START_DATE,
             spp.to_date                                                  INV_TO_DATE,
             spp.TO_DATE - spp.FROM_DATE+1                               AS inv_days,
             il.TOTAL_AMOUNT                                              INV_TOTAL_AMOUNT,
             GREATEST(spp.FROM_DATE ,srp.start_date, params.from_Date)        AS credit_period_start,
             LEAST(spp.TO_DATE,srp.end_date, params.to_date) AS
             credit_period_end,
             LEAST(spp.TO_DATE,srp.end_date, params.to_date) - GREATEST
             (spp.FROM_DATE , srp.start_date, params.from_Date) +1 AS covid_credit_days
         FROM
             SUBSCRIPTION_REDUCED_PERIOD srp
         JOIN
             subscriptions s
         ON
             s.center = srp.SUBSCRIPTION_CENTER
         AND s.id = srp.SUBSCRIPTION_ID
         LEFT JOIN
             SUBSCRIPTION_FREEZE_PERIOD sfp
         ON
             sfp.id = srp.FREEZE_PERIOD
         JOIN
             SUBSCRIPTIONPERIODPARTS spp
         ON
             spp.CENTER = s.center
         AND spp.id = s.id
         AND spp.FROM_DATE <= srp.END_DATE
         AND spp.TO_DATE >= srp.START_DATE
         AND spp.spp_state = 1
         JOIN
             SPP_INVOICELINES_LINK sppl
         ON
             sppl.PERIOD_CENTER = spp.center
         AND sppl.PERIOD_ID = spp.id
         AND sppl.PERIOD_SUBID = spp.subid
         JOIN
             INVOICE_LINES_MT il
         ON
             il.center = sppl.INVOICELINE_CENTER
         AND il.id = sppl.INVOICELINE_ID
         AND sppl.INVOICELINE_SUBID = il.subid
         JOIN
             params
         ON
             params.CENTER_ID = srp.SUBSCRIPTION_CENTER
         JOIN
             SUBSCRIPTIONTYPES st
         ON
             st.center = s.SUBSCRIPTIONTYPE_CENTER
         AND st.id = s.SUBSCRIPTIONTYPE_ID
         JOIN
             products pr
         ON
             pr.center = s.SUBSCRIPTIONTYPE_CENTER
         AND pr.id = s.SUBSCRIPTIONTYPE_ID
         WHERE
             srp.START_DATE <= params.to_date
         AND srp.END_DATE >= params.from_date
         AND srp.state = 'ACTIVE'
         AND srp.FREEZE_PERIOD IS NOT NULL
         --AND srp.text IS NULL
     ) x
 WHERE
     covid_credit_days > 0
 AND INV_TOTAL_AMOUNT > 0
 and inv_days > 0
