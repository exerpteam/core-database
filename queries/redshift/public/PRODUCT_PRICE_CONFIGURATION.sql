WITH
    xml_decode AS
    (
        SELECT
            definition_key,
            GLOBALID,
            scope_type,
            scope_id,
            convert_from(product, 'UTF-8')::xml AS xml_decoded
        FROM
            MASTERPRODUCTREGISTER
    )
    ,
    product_prices AS
    (
        SELECT
            unnest(
                CASE --xml fields are different for different product types
                    WHEN xmlexists('/subscriptionType' passing xml_decoded)=1
                    THEN (XPATH('/subscriptionType/product/prices/*', xml_decoded))
                    WHEN xmlexists('/clipcardType' passing xml_decoded)=1
                    THEN (XPATH('/clipcardType/product/prices/*', xml_decoded))
                    ELSE (XPATH('//product/prices/*', xml_decoded))
                END) AS prices_field,
            *
        FROM
            xml_decode
    )
SELECT
    definition_key AS "MASTER_PRODUCT_ID",
    GLOBALID       AS "GLOBALID",
    CASE scope_type
        WHEN 'T'
        THEN 'GLOBAL'
        WHEN 'A'
        THEN 'AREA'
        WHEN 'C'
        THEN 'CENTER'
        ELSE 'UNDEFINED'
    END  AS "SCOPE_TYPE",
    CASE scope_type
        WHEN 'T'
        THEN 0::INTEGER
        ELSE scope_id
    END                                                     AS "SCOPE_ID",
    ((xpath('/price/@start', prices_field))[1])::text::DATE                AS "PRICE_START_DATE",
    ((xpath('/price/normalPrice/text()', prices_field))[1])::text::NUMERIC AS "NORMAL_PRICE",
    ((xpath('/price/minPrice/text()', prices_field))[1])::text::NUMERIC    AS "MINIMUM_PRICE",
    ((xpath('/price/costPrice/text()', prices_field))[1])::text::NUMERIC   AS "COST_PRICE"
FROM
    product_prices 