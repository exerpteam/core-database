-- This is the version from 2026-02-05
--  
WITH
   params AS materialized
     (
select datetolongC(TO_CHAR(CURRENT_date-5, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS FROMDATE,
 datetolongC(TO_CHAR(CURRENT_date+1, 'YYYY-MM-DD HH24:MI'), 100)::bigint AS TODATE
) 
Select 
   id,
   definition_key,
   globalid,
   cached_productname,
   cached_productprice,
   cached_productcostprice,
   cached_producttype,
   cached_external_id,
   masterproductgroup,
   primary_product_group_id,
   TO_CHAR(longtodatetz(mpr.last_state_change, 'Europe/Copenhagen'),'YYYY-MM-DD HH24:MI:SS') AS "last_state_change"
   FROM params, MASTERPRODUCTREGISTER mpr
WHERE mpr.LAST_MODIFIED >= params.FROMDATE 
AND mpr.LAST_MODIFIED < params.TODATE 

