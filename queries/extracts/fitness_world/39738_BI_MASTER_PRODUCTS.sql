-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    CAST ( mp.ID AS VARCHAR(255)) "MASTER_PRODUCT_ID",
    mp.CACHED_PRODUCTNAME AS      "NAME",
    mp.STATE              AS      "STATE",
    mp.GLOBALID           AS      "GLOBALID"
--TO_CHAR(longtodateC(mp.last_modified,100),'yyyy-MM-dd')	AS "LASTMODIFIED"

FROM
    MASTERPRODUCTREGISTER mp
WHERE
    ID = DEFINITION_KEY

