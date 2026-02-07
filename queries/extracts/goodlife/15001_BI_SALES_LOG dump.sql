SELECT
  biview.*
FROM
  BI_SALES_LOG biview
WHERE
    biview."ETS" >= CAST((:from_time-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT) *24*3600*1000 
   AND biview."ETS" < CAST((:to_time-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT) *24*3600*1000 