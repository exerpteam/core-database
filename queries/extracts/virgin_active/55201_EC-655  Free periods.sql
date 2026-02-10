-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-655
 WITH
     LIST_CENTERS AS
     (
         SELECT
             /*+ materialize */
             c.ID                               AS CENTERID,
             c.shortname                        AS center,
             --TO_DATE('2020-11-20','YYYY-MM-DD') AS startdate,
             --TO_DATE('2020-12-01','YYYY-MM-DD') AS enddate
             $$FreePeriodStart$$ AS startdate,
             $$FreePeriodEnd$$ AS enddate
         FROM
             CENTERS c
         WHERE
             c.COUNTRY = 'GB'
     )
 SELECT
     lc.center,
     s.OWNER_CENTER||'p'||s.OWNER_ID Member_ID,
     to_char(srd.START_DATE,'YYYY-MM-DD') as Free_Period_Start,
     to_char(srd.END_DATE,'YYYY-MM-DD') as Free_Period_End,
     srd.TEXT
 FROM
     LIST_CENTERS lc
 JOIN
     subscriptions s
 ON
     s.owner_center = lc.centerid
 JOIN
     subscriptiontypes st
 ON
     st.center = s.subscriptiontype_center
     AND st.id = s.subscriptiontype_id
     AND st.st_type > 0 -- Except CASH
 JOIN
     subscription_reduced_period srd
 ON
     srd.subscription_center = s.center
     AND srd.subscription_id = s.id
     AND srd.state = 'ACTIVE'
     AND srd.type = 'FREE_ASSIGNMENT'
 WHERE
     srd.START_DATE <= lc.enddate
     AND srd.END_DATE >= lc.startdate
     AND s.center in ($$Scope$$)
