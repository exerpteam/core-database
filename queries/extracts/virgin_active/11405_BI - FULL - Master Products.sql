-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT (mp.id)::character varying(255) AS "MASTER_PRODUCT_ID", mp.cached_productname AS "NAME", mp.state AS "STATE", mp.globalid AS "GLOBALID" FROM masterproductregister mp WHERE (mp.id = mp.definition_key)
