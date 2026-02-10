-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11273
 SELECT
     s.OWNER_CENTER||'p'||s.OWNER_ID AS Person_ID,
     s.CENTER||'ss'||s.ID AS Subscription_ID,
     TO_CHAR(s.START_DATE,'YYYY-MM-DD')  AS Subscription_Start_Date,
     TO_CHAR(s.END_DATE,'YYYY-MM-DD')  AS Subscription_End_Date,
     CASE s.state WHEN 2 THEN 'Active' WHEN 3 THEN 'Ended' WHEN 4 THEN 'Frozen' WHEN 7 THEN 'Window' WHEN 8 THEN 'Created' ELSE 'Undefined' END AS Subscription_State,
     CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUB_STATE,
     TO_CHAR(sp.START_DATE,'YYYY-MM-DD')  AS Free_Period_StartDate,
     TO_CHAR(sp.END_DATE,'YYYY-MM-DD')  AS Free_Period_EndDate
 FROM
     SUBSCRIPTION_REDUCED_PERIOD sp
 JOIN
     SUBSCRIPTIONS s
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.ID
 WHERE
         sp.TEXT = 'COVID-19'
         AND sp.STATE != 'ACTIVE'
         AND s.SUB_STATE NOT IN (1)
