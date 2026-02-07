 SELECT s.center "Club Id"
      , c.name "Club Name"
      , p.center||'p'||p.id "Member number",
 s.center||'ss'||s.id "Subscription key"
      , p.fullname "Member name"
      , pr.name "Subscription name"
      /*, COALESCE(sp.price, s.subscription_price) "Monthly price" */
      , s.subscription_price "Subscription price" ,/* case
      when (DATE_PART('month', AGE(SS.end_DATE, SS.start_DATE))+1) < 1 then  s.subscription_price
      when ss.end_date is null then  s.subscription_price
      else  (s.subscription_price/ (DATE_PART('month', AGE(SS.end_DATE, SS.start_DATE))+1))  end as "monthly_price"  */
 CASE
WHEN  TRUNC(months_between(S.end_DATE,s.start_DATE)) < 1 THEN
    s.subscription_price
WHEN s.end_date IS NULL THEN
    s.subscription_price
ELSE
    ROUND ((s.subscription_price/ TRUNC(months_between(S.end_DATE,s.start_DATE))),2)
END AS "monthly_price"
      , s.start_date "Membership start date"
      , s.binding_end_date  "Membership binding end date"
      , s.saved_free_days "Saved Free Days"
      , s.saved_free_months "Saved Free Months"
      , (COALESCE(srp.end_date, TO_DATE(getCenterTime(s.center),'YYYY-MM-DD')) - COALESCE(srp.start_date, TO_DATE(getCenterTime(s.center),'YYYY-MM-DD'))) "Free period duration"
      , srp.start_date "Free period start date"
      , srp.end_date "Free period end date"
      , CASE
          WHEN    s.startup_free_period_id IS NULL
               OR (srp.start_date IS NOT NULL AND srp.text IS NOT NULL )
          THEN 'MANUAL'
          ELSE 'CAMPAIGN'
        END AS "Free period type"
      , cc.code "Campaign Code"
      , CASE
          WHEN    s.startup_free_period_id IS NULL
               OR (srp.start_date IS NOT NULL AND srp.text IS NOT NULL )
          THEN srp.text
          ELSE sc.name
        END AS "Free period reason",
      longtodate(srp.ENTRY_TIME) as "date free period created",
 ss.SALES_DATE                                                                            AS "Membership sale date",
 cv.txtvalue AS "Corporate value"
   FROM subscriptions s
   join   SUBSCRIPTION_SALES ss    ON s.CENTER = ss.SUBSCRIPTION_CENTER   AND s.ID = ss.SUBSCRIPTION_ID
     LEFT JOIN subscription_reduced_period srp
            ON s.center = srp.subscription_center
           AND s.id  = srp.subscription_id
           AND srp.type in ('FREE_ASSIGNMENT', 'SAVED_FREE_DAYS_USE')
           AND srp.state = 'ACTIVE'
           AND srp.end_date >= $$startdate$$
     JOIN PERSONS p
       ON s.owner_center = p.center
      AND s.owner_id = p.id
     JOIN centers c
       ON s.center = c.id
     JOIN products pr
       ON s.subscriptiontype_center = pr.center
      AND s.subscriptiontype_id = pr.id
 /*    LEFT JOIN subscription_price sp
       ON s.center = sp.subscription_center
      AND s.id  = sp.subscription_id
      AND sp.cancelled = 0
      AND COALESCE(srp.start_date, s.binding_end_date) between sp.from_date AND COALESCE(sp.to_date, COALESCE(srp.start_date, s.binding_end_date))  */
     LEFT JOIN startup_campaign sc
       ON s.startup_free_period_id = sc.id
      AND s.startup_free_period_id IS NOT NULL
     LEFT JOIN campaign_codes cc
       ON s.campaign_code_id = cc.id
      AND s.startup_free_period_id IS NOT NULL
      AND s.campaign_code_id IS NOT NULL
      LEFT JOIN
      person_ext_attrs cv
      ON
      cv.personcenter = p.center
      AND cv.personid = p.id
      AND cv.name = 'Corporatevalue'
   WHERE s.center in ($$scope$$)
     AND (   COALESCE(s.saved_free_days, 0) > 0
          OR COALESCE(s.saved_free_months, 0) > 0
          OR COALESCE(srp.id, 0) > 0
      )