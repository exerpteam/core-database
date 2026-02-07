SELECT
    mp.ID                 AS "ID",
    mp.CACHED_PRODUCTNAME AS "NAME",
    mp.STATE              AS "STATE",
    mp.GLOBALID           AS "GLOBALID",
    mp.DEFINITION_KEY     AS "TOP_NODE_ID",
    mp.SCOPE_TYPE         AS "SCOPE_TYPE",
    mp.SCOPE_ID           AS "SCOPE_ID"    
FROM
    MASTERPRODUCTREGISTER mp
    