-- This is the version from 2026-02-05
--  
WITH
    any_club_in_scope AS
    (
        SELECT
            id
        FROM
            (
                SELECT
                    id,
                    row_number() over () AS rownum
                FROM
                    centers
                WHERE
                    id IN ($$scope$$) ) x
        WHERE
            rownum =1
    ), 
    params AS
     (
         SELECT
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP)-INTERVAL '5 days', 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id)   AS FROMDATE,
             datetolongC(TO_CHAR(date_trunc('day', CURRENT_TIMESTAMP+ INTERVAL '1 days'), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id)  AS TODATE
         FROM any_club_in_scope
     )
SELECT
    pr.center || 'prod' || pr.id                                                           AS "PRODUCTID",
    pr.NAME                                                                                AS "NAME",
    replace(replace(pr.GLOBALID, chr(10), ''), chr(13), '')                                AS "GLOBALID",
    pr.external_id                                                                         AS "PRODUCTEXTERNALID",
    TO_CHAR(longtodatetz(pr.LAST_MODIFIED,'Europe/Copenhagen'),'YYYY-MM-DD HH24:MI:SS')    AS "LASTMODIFIEDDATE",
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
CROSS JOIN PARAMS
WHERE
    pr.CENTER in ($$scope$$)
    AND pr.LAST_MODIFIED >= PARAMS.FROMDATE
    AND pr.LAST_MODIFIED < PARAMS.TODATE