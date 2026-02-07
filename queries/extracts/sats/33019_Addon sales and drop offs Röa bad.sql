 SELECT
     c.NAME,
     c.ID                          AS "Scope",
     COALESCE(mpr.GLOBALID,pr.GLOBALID) AS GLOBALID,
     SUM(
         CASE
             WHEN sa.START_DATE BETWEEN $$start_date$$ AND $$end_date$$
             THEN 1
             WHEN pr.GLOBALID = 'Badeland EFT add-on'
                 AND s.START_DATE BETWEEN $$start_date$$ AND $$end_date$$
             THEN 1
             ELSE 0
         END) AS "new",
     SUM(
         CASE
             WHEN sa.END_DATE BETWEEN $$start_date$$ AND $$end_date$$
             THEN 1
             WHEN pr.GLOBALID = 'Badeland EFT add-on'
                 AND s.END_DATE BETWEEN $$start_date$$ AND $$end_date$$
             THEN 1
             ELSE 0
         END) AS "DropOff",
     SUM(
         CASE
             WHEN sa.END_DATE > $$end_date$$
                 AND sa.START_DATE <=$$end_date$$
             THEN 1
             WHEN sa.END_DATE IS NULL
                 AND sa.ID IS NOT NULL
                 AND sa.START_DATE <=$$end_date$$
             THEN 1
             WHEN pr.GLOBALID = 'Badeland EFT add-on'
                 AND s.END_DATE > $$end_date$$
                 AND s.START_DATE <=$$end_date$$
             THEN 1
             WHEN pr.GLOBALID = 'Badeland EFT add-on'
                 AND s.END_DATE IS NULL
                 AND s.START_DATE <=$$end_date$$
             THEN 1
             ELSE 0
         END ) AS "Ultimo Balance"
 FROM
     SUBSCRIPTIONS s
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     SUBSCRIPTION_ADDON sa
 ON
     s.center = sa.SUBSCRIPTION_CENTER
     AND s.id = sa.SUBSCRIPTION_ID
 LEFT JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.id = sa.ADDON_PRODUCT_ID
 JOIN
     CENTERS c
 ON
     c.id = s.CENTER
 WHERE
     s.center IN ($$scope$$)
     AND (
         sa.ID IS NOT NULL
         OR pr.GLOBALID = 'Badeland EFT add-on')
 GROUP BY
     c.NAME,
     c.ID,
     COALESCE(mpr.GLOBALID,pr.GLOBALID)
