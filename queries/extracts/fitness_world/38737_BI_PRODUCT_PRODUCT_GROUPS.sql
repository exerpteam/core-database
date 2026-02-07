-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    ppgl.PRODUCT_CENTER||'prod'||ppgl.PRODUCT_ID  AS "PRODUCT_ID",
    CAST ( ppgl.PRODUCT_GROUP_ID AS VARCHAR(255)) AS "PRODUCT_GROUP_ID",
    REPLACE(TO_CHAR(pr.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    params,
    PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
JOIN
    PRODUCTS pr
ON
    pr.center = ppgl.PRODUCT_CENTER
    AND pr.id = ppgl.PRODUCT_ID
WHERE
    pr.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
