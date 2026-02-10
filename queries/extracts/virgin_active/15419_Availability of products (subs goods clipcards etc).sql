-- The extract is extracted from Exerp on 2026-02-08
-- Lista completa prodotti (sub/goods/clipcard/etc): 1 riga per ogni club in cui è disponibile + specifica global name
 SELECT
 distinct
         MPR.CACHED_PRODUCTNAME "Product Name",
         MPR.GLOBALID "Global Product ID",
         C.NAME "Club Name"
 FROM
         PRODUCT_AVAILABILITY PA
 JOIN
         MASTERPRODUCTREGISTER MPR
 ON
         MPR.DEFINITION_KEY = PA.PRODUCT_MASTER_KEY
 JOIN
         CENTERS C
 ON
         PA.SCOPE_ID = C.ID AND PA.SCOPE_TYPE = 'C'
 join
         products p
 ON
         mpr.globalID=p.globalID
 WHERE
         MPR.STATE = 'ACTIVE'
 AND
         C.ID in ($$Scope$$)
 AND
         p.center IN ($$Scope$$)
