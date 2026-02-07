 SELECT
     c.country AS "Country",
     c.shortname AS "Center",
     c.id AS "CenterID",
     pg.name AS "Product Group Name",
     pr.name AS "Product Name",
     brand.name as brand,
     COALESCE(ivat.RATE,0) AS "VAT Rate",
     COALESCE(rg.name, stc.name) AS  "Campaign/privilege discount",
     SUM(il.quantity) AS "Sales Count",
     SUM(pr.cost_price) AS "Product Cost",
     ROUND(SUM(il.PRODUCT_NORMAL_PRICE - (il.TOTAL_AMOUNT / il.QUANTITY)),2) AS "Discount Amount",
     SUM(il.total_amount) AS "Total Sales Amount",
     SUM(il.total_amount) - SUM(il.net_amount) AS  "VAT Amount",
     SUM(il.net_amount) AS "Total Sales Amount ExclVat"
 FROM
     INVOICES i
 JOIN
     invoice_lines_mt il
 ON
     i.center = il.center
     AND i.id = il.id
 JOIN
    PRODUCTS pr
 ON
    il.Productcenter = pr.center
    AND il.PRODUCTID = pr.ID
 JOIN
    product_group pg
 ON
    pr.primary_product_group_id = pg.id
 JOIN
    centers c
 ON
    c.ID = i.CENTER
 left join (Select
 pr.center,
 pr.id,
 pg2.name as name
 from products pr
 join  PRODUCT_AND_PRODUCT_GROUP_LINK ppg
 on
 ppg.PRODUCT_CENTER = pr.center
 and
 ppg.PRODUCT_ID = pr.id
 join product_group pg2
 on
 ppg.PRODUCT_GROUP_ID = pg2.id
 where
 pg2.name like '4.%%') brand
 on
 brand.center = pr.center
 and
 brand.id = pr.id
 LEFT JOIN
    INVOICELINES_VAT_AT_LINK ivat
 ON
    il.CENTER = ivat.INVOICELINE_CENTER
    AND il.ID = ivat.INVOICELINE_ID
    AND il.SUBID = ivat.INVOICELINE_SUBID
 LEFT JOIN
    PRIVILEGE_USAGES pu
 ON
    pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.TARGET_CENTER = il.CENTER
    AND pu.TARGET_ID = il.ID
    AND pu.TARGET_SUBID = il.SUBID
 LEFT JOIN
     PRIVILEGE_GRANTS pgr
 ON
     pgr.ID = pu.GRANT_ID
     AND pgr.GRANTER_SERVICE in ('StartupCampaign','ReceiverGroup')
 LEFT JOIN
     PRIVILEGE_RECEIVER_GROUPS rg
 ON
     pgr.GRANTER_SERVICE = 'ReceiverGroup'
     AND rg.ID = pgr.GRANTER_ID
 LEFT JOIN
     startup_campaign stc
 ON
     pgr.GRANTER_SERVICE = 'StartupCampaign'
     AND stc.ID = pgr.GRANTER_ID
 WHERE
    c.ID IN (:Scope)
    AND i.entry_time BETWEEN :StartDate AND  :StopDate + 24*60*60*1000-1
    AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl WHERE pl.PRODUCT_GROUP_ID = 38203 AND pr.ID = pl.PRODUCT_ID AND pr.CENTER = pl.PRODUCT_CENTER)  -- EFT binding memberships
 GROUP BY
    c.country,
    c.shortname,
    c.id,
    pg.name,
    brand.name,
    pr.name,
    COALESCE(ivat.RATE,0),
    COALESCE(rg.name, stc.name)
 UNION ALL
    SELECT
     c.country AS "Country",
     c.shortname AS "Center",
     c.id AS "CenterID",
     pg.name AS "Product Group Name",
     brand.name as brand,
     pr.name AS "Product Name",
     COALESCE(cvat.RATE,0) AS "VAT Rate",
     COALESCE(rg.name, stc.name) AS  "Campaign/privilege discount",
     -SUM(cl.quantity) AS "Sales Count",
     -SUM(pr.cost_price) AS "Product Cost",
     null AS "Discount Amount",
     -SUM(cl.total_amount) AS "Total Sales Amount",
     -(SUM(cl.total_amount) - SUM(cl.net_amount)) AS  "VAT Amount",
     -SUM(cl.net_amount) AS "Total Sales Amount ExclVat"
 FROM
     CREDIT_NOTES cn
 JOIN
     CREDIT_NOTE_LINES_MT cl
 ON
     cn.center = cl.center
     AND cn.id = cl.id
 JOIN
    PRODUCTS pr
 ON
    cl.Productcenter = pr.center
    AND cl.PRODUCTID = pr.ID
 JOIN
    product_group pg
 ON
    pr.primary_product_group_id = pg.id
 JOIN
    centers c
 ON
    c.ID = cn.CENTER
 left join (Select
 pr.center,
 pr.id,
 pg2.name as name
 from products pr
 join  PRODUCT_AND_PRODUCT_GROUP_LINK ppg
 on
 ppg.PRODUCT_CENTER = pr.center
 and
 ppg.PRODUCT_ID = pr.id
 join product_group pg2
 on
 ppg.PRODUCT_GROUP_ID = pg2.id
 where
 pg2.name like '4.%%') brand
 on
 brand.center = pr.center
 and
 brand.id = pr.id
 LEFT JOIN
     CREDIT_NOTE_LINE_VAT_AT_LINK cvat
 ON
     cl.CENTER = cvat.CREDIT_NOTE_LINE_CENTER
     AND cl.ID = cvat.CREDIT_NOTE_LINE_ID
     AND cl.SUBID = cvat.CREDIT_NOTE_LINE_SUBID
 LEFT JOIN
    PRIVILEGE_USAGES pu
 ON
    pu.TARGET_SERVICE = 'InvoiceLine'
    AND pu.TARGET_CENTER = cl.INVOICELINE_CENTER
    AND pu.TARGET_ID = cl.INVOICELINE_ID
    AND pu.TARGET_SUBID = cl.INVOICELINE_SUBID
 LEFT JOIN
     PRIVILEGE_GRANTS pgr
 ON
     pgr.ID = pu.GRANT_ID
     AND pgr.GRANTER_SERVICE in ('StartupCampaign','ReceiverGroup')
 LEFT JOIN
     PRIVILEGE_RECEIVER_GROUPS rg
 ON
     pgr.GRANTER_SERVICE = 'ReceiverGroup'
     AND rg.ID = pgr.GRANTER_ID
 LEFT JOIN
     startup_campaign stc
 ON
     pgr.GRANTER_SERVICE = 'StartupCampaign'
     AND stc.ID = pgr.GRANTER_ID
 WHERE
    c.ID IN (:Scope)
    AND cn.entry_time BETWEEN :StartDate AND  :StopDate + 24*60*60*1000-1
 AND NOT EXISTS (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl WHERE pl.PRODUCT_GROUP_ID = 38203 AND pr.ID = pl.PRODUCT_ID AND pr.CENTER = pl.PRODUCT_CENTER)  -- EFT binding memberships
 GROUP BY
    c.country,
    c.shortname,
    c.id,
    pg.name,
    pr.name,
    brand.name,
    COALESCE(cvat.RATE,0),
    COALESCE(rg.name, stc.name)
