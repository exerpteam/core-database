-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11092
 WITH
     params AS materialized
     (
         SELECT
                 CAST($$FreeFromDate$$ AS DATE) AS StartDate,
                 CAST($$FreeToDate$$ AS DATE) AS EndDate
         
     )
 SELECT
     s.owner_center || 'p' || s.owner_id     AS Person_Id,
     s.center || 'ss' || s.id                AS Subscription_Id,
     to_char(s.start_date,'YYYY-MM-DD')          AS Subscription_Start_Date,
     to_char(srd.start_date,'YYYY-MM-DD')        AS Free_Start_Date,
         to_char(srd.end_date,'YYYY-MM-DD')          AS Free_End_Date,
         srd.TEXT AS Free_Comment,
         srd.TYPE,
         sf.TYPE                                 AS Freeze_Type,
         sf.TEXT AS Freeze_Comment,
         CASE st.st_type WHEN 0 THEN 'CASH' WHEN 1 THEN 'EFT' END     AS Subscription_Type,
 CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
 FROM
     subscriptions s
 CROSS JOIN
     params
 JOIN
     subscriptiontypes st
 ON
     st.center = s.SUBSCRIPTIONTYPE_CENTER
     AND st.id = s.SUBSCRIPTIONTYPE_id
 JOIN PERSONS p
 ON
         p.CENTER = s.OWNER_CENTER
         AND p.ID = s.OWNER_ID
 JOIN
     subscription_reduced_period srd
 ON
     srd.subscription_center = s.center
     AND srd.subscription_id = s.id
     AND srd.state = 'ACTIVE'
     AND srd.start_date <= params.EndDate
     AND srd.end_date >= params.startdate
 LEFT JOIN
         subscription_freeze_period sf
 ON
         sf.ID = srd.FREEZE_PERIOD
 WHERE
     s.owner_center IN ($$Scope$$)
         AND srd.ID IS NOT NULL
         -- exclude subscriptions from those product groups
         AND NOT EXISTS
         (
                 SELECT
                         1
                 FROM
                         PRODUCT_AND_PRODUCT_GROUP_LINK ppl
                 WHERE
                         ppl.product_center = st.center
                         AND ppl.product_id = st.id
                         AND ppl.PRODUCT_GROUP_ID in (401,801,6409)
         )
         AND (s.CENTER,s.ID) IN ($$subList$$)
