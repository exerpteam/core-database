-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-12717
 -- CHECK END_DATES
 -- CHECK NO MORE THAN 2 SUBSCRIPTIONS
 -- CHECK SUB_STATES
 WITH params AS MATERIALIZED
 (
         SELECT
                 c.ID AS CENTERID,
                 TO_DATE('2020-03-21','YYYY-MM-DD') AS StartDate,
         CAST($$ClubOpeningDate$$ AS DATE) -1           AS EndDate
         FROM CENTERS c
         WHERE
                 CAST(c.ID AS VARCHAR) IN ($$Scope$$)
 )
         SELECT
                 t3.*,
                 sp.PRICE AS FUTURE_PRICE,
                                 TO_CHAR(t3.START_OVERLAP + t3.OVERLAP,'YYYY-MM-DD') AS FUTURE_PRICE_START_DATE
         FROM
         (
                 SELECT
                         t2.*
                 FROM
                 (
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
                                                                 t1.billed_until_date,
                                 t1.BINDING_PRICE,
                                 t1.STATE,
                                 t1.PROD_PRICE,
                                 t1.PARAM_END_DATE,
                                 t1.SubCenter,
                                 t1.SubId,
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
                                         WHEN sp.TO_DATE > EndDate THEN sp.TO_DATE + 1
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
                                                                         s.billed_until_date,
                                     s.BINDING_PRICE,
                                     s.STATE,
                                     s.center as SubCenter,
                                     s.id as SubId,
                                     par.EndDate AS PARAM_END_DATE,
                                     pr.PRICE AS PROD_PRICE
                                 FROM
                                     SUBSCRIPTIONS s
                                 JOIN PERSONS p ON s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID AND p.PERSONTYPE != 4
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
                                                                         par.CENTERID = p.center
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
                                 s.STATE IN (2,4)
                                 AND sp.FROM_DATE <= par.EndDate
                                 AND sp.TO_DATE >= par.StartDate
                                                                 AND NOT EXISTS
                                     (
                                         SELECT
                                             1
                                         FROM
                                             subscription_price sp1
                                         WHERE
                                             sp1.SUBSCRIPTION_CENTER = s.center
                                             AND sp1.SUBSCRIPTION_ID = s.Id
                                             AND sp1.CANCELLED = 0
                                             AND sp1.coment = 'COVID-19 Price Extension')
                         ) t1
                         LEFT JOIN    SUBSCRIPTION_PRICE sp
                                 ON sp.SUBSCRIPTION_CENTER = t1.SubCenter AND sp.SUBSCRIPTION_ID = t1.SubId AND sp.FROM_DATE > PARAM_END_DATE AND sp.CANCELLED = 0
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
                                                                 t1.billed_until_date,
                                 t1.BINDING_PRICE,
                                 t1.STATE,
                                 t1.PROD_PRICE,
                                 t1.PARAM_END_DATE,
                                 t1.SubCenter,
                                 t1.SubId
                 ) t2
                 WHERE t2.PRICE_UPDATE_IN_FUTURE = 1
         ) t3
         JOIN SUBSCRIPTION_PRICE sp
                 ON sp.SUBSCRIPTION_CENTER = t3.SubCenter AND sp.SUBSCRIPTION_ID = t3.SubId AND sp.FROM_DATE > t3.PARAM_END_DATE AND sp.CANCELLED = 0
