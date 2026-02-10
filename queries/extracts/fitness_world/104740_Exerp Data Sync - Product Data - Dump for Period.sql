-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    pr.center || 'prod' || pr.id                                                            AS "PRODUCTID",
    pr.NAME                                                                                 AS "NAME",
    replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '')                                 AS "GLOBALID",
    pr.external_id                                                                          AS "PRODUCTEXTERNALID",
    TO_CHAR(longtodatetz(pr.LAST_MODIFIED,'Europe/Copenhagen'),'YYYY-MM-DD HH24:MI:SS')     AS "LASTMODIFIEDDATE",
    TO_CHAR(pr.PRICE,'FM999999990.00') AS "PRICE",
    CASE ppgl.PRODUCT_GROUP_ID
        WHEN 25402 THEN 'true'
        ELSE 'false'
    END AS "SubscriptionIncludesClasses"
FROM
    PRODUCTS pr
    LEFT JOIN 
    (
        SELECT PRODUCT_GROUP_ID, PRODUCT_CENTER, PRODUCT_ID 
        FROM PRODUCT_AND_PRODUCT_GROUP_LINK
        WHERE PRODUCT_GROUP_ID = 25402
        AND PRODUCT_CENTER IN ($$scope$$)
    ) ppgl
    ON pr.center = ppgl.PRODUCT_CENTER
    AND pr.id = ppgl.PRODUCT_ID
WHERE
    pr.CENTER in ($$scope$$)
