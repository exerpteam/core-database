-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            datetolongTZ(TO_CHAR(date_trunc('day', CURRENT_DATE)- INTERVAL '5 days', 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen')::bigint AS FROMDATE,
            datetolongTZ(TO_CHAR(date_trunc('day', CURRENT_DATE+INTERVAL '1 days'), 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen')::bigint AS TODATE
    )
SELECT
DISTINCT pg.NAME AS "Product Group Name",
mpr.GLOBALID AS "Product ID",
mpr.state AS "Product State",
mpa.PRODUCT_GROUP_ID AS "Product_Group_ID"
FROM params, PRODUCT_GROUP pg
LEFT JOIN
MASTER_PROD_AND_PROD_GRP_LINK mpa
ON pg.ID = mpa.PRODUCT_GROUP_ID
LEFT JOIN MASTERPRODUCTREGISTER mpr
ON mpa.MASTER_PRODUCT_ID = mpr.ID
WHERE pg.state = 'ACTIVE'
AND mpr.STATE != 'DELETED'
  AND (MPR.CACHED_PRODUCTNAME NOT LIKE '%(gl)%' --other products with (gl) are not needed for historical unpaid transactions 
	   OR MPR.CACHED_PRODUCTNAME = 'FW rygsæk (gl)' --taken for historical unpaid transactions
	   OR MPR.CACHED_PRODUCTNAME = 'FW Træningstaske (gl)' --taken for historical unpaid transactions
	   ) 
  AND MPR.CACHED_PRODUCTNAME NOT LIKE '%EB tilmeld%' --no PT vouchers
AND pg.NAME NOT LIKE '%test%'
AND pg.LAST_MODIFIED >= params.FROMDATE
AND pg.LAST_MODIFIED < params.TODATE