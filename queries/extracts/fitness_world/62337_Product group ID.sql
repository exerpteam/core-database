-- The extract is extracted from Exerp on 2026-02-08
--  
Select
DISTINCT pg.NAME AS "Product Group Name",
mpr.GLOBALID AS "Product ID",
mpr.state AS "Product State",
mpa.PRODUCT_GROUP_ID AS "Product_Group_ID"
from PRODUCT_GROUP pg
Left join
MASTER_PROD_AND_PROD_GRP_LINK mpa
ON pg.ID = mpa.PRODUCT_GROUP_ID
left join MASTERPRODUCTREGISTER mpr
ON mpa.MASTER_PRODUCT_ID = mpr.ID
Where pg.state = 'ACTIVE'
AND mpr.STATE != 'DELETED'
  AND (MPR.CACHED_PRODUCTNAME not like '%(gl)%' --other products with (gl) are not needed for historical unpaid transactions 
	   OR MPR.CACHED_PRODUCTNAME = 'FW rygsæk (gl)' --taken for historical unpaid transactions
	   OR MPR.CACHED_PRODUCTNAME = 'FW Træningstaske (gl)' --taken for historical unpaid transactions
	   ) 
  AND MPR.CACHED_PRODUCTNAME NOT LIKE '%EB tilmeld%' --no PT vouchers
AND pg.NAME NOT LIKE '%test%'
ORDER BY pg.name
