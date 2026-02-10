-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    xml_decode AS
    (
        SELECT
            definition_key,
            GLOBALID,
            scope_type,
            scope_id,
            CAST(convert_from(product, 'UTF-8') AS xml) AS xml_decoded
        FROM
            MASTERPRODUCTREGISTER
    )
    ,
   freeze_price AS
    (  
            SELECT 
                CAST(CAST(unnest((XPATH('/subscriptionType/freeze/period/product/prices/price/normalPrice/text()', xml_decoded))) AS Text) AS NUmeric) AS normal_price,
                --CAST(CAST(((xpath('/normalPrice/text()', prices_field))[1]) AS text) AS NUMERIC) AS normal_price,             
                *
            FROM xml_decode 
     )
SELECT
        p.center||'p'||p.id AS PersonID
        ,s.center||'ss'||s.id AS subscription_id
        ,srp.start_date as freeze_start_date
        ,spp.subscription_price AS freeze_price
        ,freeze_price.normal_price AS current_freeze_price
FROM
         subscriptions s
JOIN
         subscription_reduced_period srp
        ON s.center = srp.subscription_center
        AND s.id = srp.subscription_id
JOIN
         subscriptionperiodparts spp
        ON spp.center = s.center
        AND spp.id = s.id
        AND srp.start_date = spp.from_date
JOIN
         products pr
        ON s.subscriptiontype_center = pr.center
        AND s.subscriptiontype_id = pr.id
LEFT JOIN
        freeze_price 
        ON freeze_price.globalid = pr.globalid
        AND freeze_price.scope_id = pr.center        
JOIN
         persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
WHERE
        spp.spp_state = 1
        AND
        spp.spp_type = 2
        AND
        srp.type = 'FREEZE'
        AND 
        srp.state = 'ACTIVE'
        AND
        srp.end_date > current_date
        AND
        spp.subscription_price != freeze_price.normal_price 
      
 