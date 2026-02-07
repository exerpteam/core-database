 SELECT
     s.CENTER ||'ss'|| s.ID AS "Subscription ID",
     p.EXTERNAL_ID AS "External ID",
     p.CENTER||'p'||p.ID AS "Person ID",
     c.SHORTNAME AS Gym_Name,
     c.ID AS "Gym ID",
     prod_addon.name AS "Add-on Name",
     prod_addon.PRICE AS "Add-on Price",
     TO_CHAR(sa.START_DATE,'YYYY-MM-DD') AS "Add-on Start Date",
     TO_CHAR(sa.END_DATE,'YYYY-MM-DD') AS "Add-on End Date",
     CASE WHEN sa.END_DATE = NULL
       THEN null
       ELSE sa.END_DATE-sa.START_DATE
     END AS "Days Active",
     SUM(cl.TOTAL_AMOUNT) As "Price for Period"
 FROM
     SUBSCRIPTION_ADDON sa
 JOIN
     SUBSCRIPTIONS s
 ON
     s.center = sa.SUBSCRIPTION_CENTER
     AND s.id = sa.SUBSCRIPTION_ID
 JOIN
     PERSONS p
 ON
     p.center = s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 JOIN
     MASTERPRODUCTREGISTER mpr_addon
 ON
     mpr_addon.id = sa.ADDON_PRODUCT_ID
 JOIN
     PRODUCTS prod_addon
 ON
     prod_addon.center = sa.CENTER_ID
     AND prod_addon.GLOBALID = mpr_addon.GLOBALID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 JOIN
     credit_note_lines_mt cl
 ON
     prod_addon.center = cl.PRODUCTCENTER
     AND prod_addon.id = cl.PRODUCTID
     AND p.CENTER = cl.PERSON_CENTER
     AND p.ID = cl.PERSON_ID
 JOIN
     CREDIT_NOTES cn
 ON
     cl.center = cn.center
     AND cl.id = cn.id
 WHERE
     p.CENTER in (:Scope)
     AND sa.START_DATE >= :From_Date
     AND sa.START_DATE <= :End_Date
     AND s.STATE NOT IN (2,4,8)
     AND p.STATUS <> 4 --not transferred
     AND sa.START_DATE < sa.END_DATE
     AND cn.TEXT = 'Addon sale API'
 GROUP BY s.CENTER||'ss'||s.ID, p.EXTERNAL_ID, p.CENTER||'p'||p.ID,c.SHORTNAME,c.ID,prod_addon.name,prod_addon.PRICE,sa.START_DATE,sa.END_DATE
