-- This is the version from 2026-02-05
--  
WITH
        pricetiers AS
        (
          SELECT
                prod.center,
                prod.price
          FROM
          products prod
          JOIN PRODUCT_AND_PRODUCT_GROUP_LINK prodlink
          ON prodlink.PRODUCT_CENTER = prod.CENTER
		  AND prodlink.PRODUCT_ID = prod.ID
          JOIN product_group prodg
          ON prodg.id = prodlink.product_group_id
          AND prodg.ID = 32801
          WHERE prod.NAME = 'Plus'
          AND prod.blocked = false
          AND prod.external_id not like '%UPGRADE%'
          AND prod.center != 100
        )
SELECT
ss.SUBSCRIPTION_CENTER ||'ss'|| ss.SUBSCRIPTION_ID AS subscription_id,
pr.name product_name,
TO_CHAR(ss.sales_DATE, 'YYYY-MM-DD') AS sales_date,
TO_CHAR(ss.start_date, 'YYYY-MM-DD') AS start_date,
CASE
	WHEN pr.NAME in ('Core', 'Core og Hold', 'Plus')
	THEN CAST(pt.price AS INT)
	ELSE null
	END AS price_tier,
ss.SUBSCRIPTION_CENTER subscription_center,
pr.price::numeric AS product_price
from
subscription_sales ss
JOIN products pr
ON pr.CENTER = ss.SUBSCRIPTION_TYPE_CENTER
AND pr.ID = ss.SUBSCRIPTION_TYPE_ID
AND pr.ptype = 10
JOIN pricetiers pt
ON pt.center = ss.SUBSCRIPTION_CENTER
WHERE
ss.SALES_DATE >= current_date - 1
AND ss.SALES_DATE < current_date
AND pr.name in ('Core', 'Core og Hold', 'Plus', 'Fitness All', 'Fitness Basic', 'Fitness Flex', 'Fitness Premium', 'Hold All', 'Hold Basic', 'Hold Flex', 'Hold Premium')
AND ss.CANCELLATION_DATE is null
AND ss.type = 1
AND ss.SUBSCRIPTION_CENTER IN (:SCOPE)
ORDER BY
ss.SALES_DATE,
ss.SUBSCRIPTION_CENTER,
pr.NAME,
pt.price
