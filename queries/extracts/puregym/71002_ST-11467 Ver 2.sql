 WITH params AS MATERIALIZED
 (
         SELECT
                 c.ID AS CENTERID,
                 CAST($$StartDate$$ AS DATE) AS StartDate,
                 CAST($$EndDate$$ AS DATE)   AS EndDate
         FROM CENTERS c
         WHERE
                 CAST(c.ID AS VARCHAR) IN (:Scope)
 )
 SELECT
         t1.NAME,
         t1.CAMPAIGN_NAME,
         t1.PRIV_USAGE_STATE,
         t1.TARGET_SERVICE,
         t1.USE_TIME,
         t1.FROM_DATE,
         t1.TO_DATE,
         t1.START_OVERLAP,
         t1.OVERLAP,
         t1.PRICE,
         t1.TYPE,
         t1.SUBSCRIPTION_ID,
         t1.PERSON_ID,
         t1.START_DATE,
         t1.END_DATE,
         t1.SUBSCRIPTION_PRICE,
         t1.BINDING_PRICE,
         t1.STATE,
         SUM(CASE WHEN sp.ID IS NOT NULL THEN 1 ELSE 0 END) AS PRICE_UPDATE_IN_FUTURE
 FROM
 (
 SELECT
     pr.NAME,
     sc.NAME AS CAMPAIGN_NAME,
     pu.STATE AS PRIV_USAGE_STATE,
     pu.TARGET_SERVICE,
     LONGTODATEC(pu.USE_TIME, s.CENTER) AS USE_TIME,
     sp.FROM_DATE,
     sp.TO_DATE,
     CASE
         WHEN sp.TO_DATE > EndDate THEN sp.TO_DATE +1
         WHEN sp.TO_DATE <= EndDate THEN endDate + 1
     END AS START_OVERLAP,
     CASE
         WHEN sp.FROM_DATE > StartDate AND sp.TO_DATE < EndDate THEN (sp.TO_DATE - sp.FROM_DATE +1)
         WHEN sp.FROM_DATE > StartDate AND sp.TO_DATE >= EndDate THEN (EndDate - sp.FROM_DATE +1)
         WHEN sp.TO_DATE < EndDate THEN (sp.TO_DATE - StartDate + 1)
         WHEN sp.TO_DATE >= EndDate THEN (EndDate - StartDate +1)
     END AS OVERLAP,
     sp.PRICE,
     sp.TYPE,
     sp.CANCELLED,
     s.CENTER || 'ss' || s.ID            AS SUBSCRIPTION_ID,
     s.OWNER_CENTER || 'p' || s.OWNER_ID AS PERSON_ID,
     s.START_DATE,
     s.END_DATE,
     s.SUBSCRIPTION_PRICE,
     s.BINDING_PRICE,
     s.STATE,
     s.center as SubCenter,
     s.id as SubId,
         par.EndDate AS PARAM_END_DATE
 FROM
     SUBSCRIPTIONS s
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
 JOIN
     PRODUCTS pr
 ON
     st.CENTER = pr.CENTER AND st.ID = pr.ID
 JOIN
     PARAMS par
 ON
    par.CENTERID = s.OWNER_CENTER
 JOIN
     SUBSCRIPTION_PRICE sp
 ON
     s.CENTER = sp.SUBSCRIPTION_CENTER
 AND s.ID = sp.SUBSCRIPTION_ID
 JOIN
     PRIVILEGE_USAGES pu
 ON
     sp.ID = pu.TARGET_ID
 AND pu.TARGET_SERVICE = 'SubscriptionPrice'
 JOIN
     PRIVILEGE_GRANTS pg
 ON
     pu.GRANT_ID = pg.ID
 JOIN
     STARTUP_CAMPAIGN sc
 ON
     pg.GRANTER_SERVICE = 'StartupCampaign'
 AND pg.GRANTER_ID = sc.ID
 WHERE
     --s.OWNER_CENTER = 238 AND s.OWNER_ID = 34692 AND
     CAST(s.OWNER_CENTER AS VARCHAR) IN ($$Scope$$)
     AND s.STATE IN (2,4,8)
 AND sp.FROM_DATE <= par.EndDate
 AND sp.TO_DATE >= par.StartDate
 ) t1
 LEFT JOIN    SUBSCRIPTION_PRICE sp
         ON sp.SUBSCRIPTION_CENTER = t1.SubCenter AND sp.SUBSCRIPTION_ID = t1.SubId AND sp.FROM_DATE >= PARAM_END_DATE AND sp.CANCELLED = false
 GROUP BY
         t1.NAME,
         t1.CAMPAIGN_NAME,
         t1.PRIV_USAGE_STATE,
         t1.TARGET_SERVICE,
         t1.USE_TIME,
         t1.FROM_DATE,
         t1.TO_DATE,
         t1.START_OVERLAP,
         t1.OVERLAP,
         t1.PRICE,
         t1.TYPE,
         t1.SUBSCRIPTION_ID,
         t1.PERSON_ID,
         t1.START_DATE,
         t1.END_DATE,
         t1.SUBSCRIPTION_PRICE,
         t1.BINDING_PRICE,
         t1.STATE
