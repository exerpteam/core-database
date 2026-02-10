-- The extract is extracted from Exerp on 2026-02-08
-- All active subscription products excluing moorgate
select 

PRODUCTS.CENTER,
PRODUCTS.ID, 
PRODUCTS.NAME, 
PRODUCTS.EXTERNAL_ID,
PRODUCTS.PRICE,
PRODUCTS.GLOBALID,
PRODUCTS.SHOW_ON_WEB

from PUREGYM.PRODUCTS


where PTYPE = 10 AND BLOCKED = 0 and CENTER not in (701)

