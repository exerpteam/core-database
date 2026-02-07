WITH
    params AS
    (
        SELECT
            DECODE(:offset,0,0,(TRUNC(exerpsysdate())-:offset-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )

SELECT
    p.PRODUCT_ID
  , p.PRODUCT_CENTER
  , p.MASTER_PRODUCT_ID
  , p.NAME
  , p.PRODUCT_TYPE
  , p.EXTERNAL_ID
  , p.SALES_PRICE
  , p.MINIMUM_PRICE
  , p.COST_PRICE
  , p.PRODUCT_GROUP_ID
  , p.BLOCKED,
p.ETS
FROM
   BI_PRODUCTS p
CROSS JOIN
    params
WHERE p.ETS >= PARAMS.FROMDATE
    AND p.ETS < PARAMS.TODATE