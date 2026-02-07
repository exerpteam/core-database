SELECT
    c.NAME,
    c.ID AS "Scope",
    mpr.GLOBALID,
    SUM(
        CASE
            WHEN sa.START_DATE BETWEEN $$start_date$$ AND $$end_date$$
            THEN 1
            ELSE 0
        END) AS "new",
    SUM(
        CASE
            WHEN sa.END_DATE BETWEEN $$start_date$$ AND $$end_date$$
            THEN 1
            ELSE 0
        END)     AS "DropOff",
  sum(CASE
            WHEN (sa.END_DATE > $$end_date$$ or sa.end_date is null) and sa.start_date<=$$end_date$$
            THEN 1
            ELSE 0
        END) AS "Ultimo Balance"
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    s.center = sa.SUBSCRIPTION_CENTER
    AND s.id = sa.SUBSCRIPTION_ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.id = sa.ADDON_PRODUCT_ID
JOIN
    CENTERS c
ON
    c.id = s.CENTER
WHERE
    s.center IN ($$scope$$)
GROUP BY
    c.NAME,
    c.ID,
    mpr.GLOBALID