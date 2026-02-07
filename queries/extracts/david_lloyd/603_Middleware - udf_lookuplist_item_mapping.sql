-- This is the version from 2026-02-05
--  
WITH
    ext_arr_values AS
    (SELECT
        CAST((xpath('//attribute/@id',xml_element))[1] AS     TEXT)              AS field_id
        ,CAST((xpath ('//attribute/@name',xml_element))[1] AS TEXT)                    AS field_name
        , CAST((xpath('//attribute/@type',xml_element))[1] AS TEXT)                    AS field_type
        , unnest((xpath('//attribute/possibleValues/possibleValue/text()',xml_element))) AS
        field_value
        , unnest((xpath('//attribute/possibleValues/possibleValue/@id',xml_element))) AS
        field_value_id
        , xml_element
    FROM
        ( SELECT
            s.id
            , s.scope_type
            , s.scope_id
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(s.mimevalue, 'UTF-8')) ))
            AS xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
        AND s.mimetype = 'text/xml') t
    )
    , ext_arr AS
    (SELECT
        DISTINCT CAST((xpath('//attribute/@id',xml_element))[1] AS           TEXT) AS field_id
        ,CAST((xpath ('//attribute/@name',xml_element))[1] AS                TEXT) AS field_name
        , CAST((xpath('//attribute/@type',xml_element))[1] AS                TEXT) AS field_type
        , CAST((xpath('//attribute/@usingPossibleValues',xml_element))[1] AS TEXT) AS
        usingPossibleValues
    FROM
        ( SELECT
            s.id
            , s.scope_type
            , s.scope_id
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(s.mimevalue, 'UTF-8')) ))
            AS xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
        AND s.mimetype = 'text/xml') t
    )
    , udf_mapping AS
    ( SELECT
        ext_arr.field_id
        , ext_arr.field_name
        , CASE
            WHEN ext_arr.usingPossibleValues = 'true'
            THEN 'Lookup'
            WHEN ext_arr.field_type = 'long_text' 
            THEN 'string'
            ELSE ext_arr.field_type
        END AS field_type
        , CASE
            WHEN ext_arr.field_type = 'string'
            AND ext_arr.usingPossibleValues = 'true'
            THEN MAX(LENGTH(CAST(field_value AS TEXT)))
            WHEN ext_arr.field_type IN('string' 
                                       ,'long_text')
            AND NOT (
                    ext_arr.usingPossibleValues = 'true')
            THEN 1024
        END AS max_length
    FROM
        ext_arr
    LEFT JOIN
        ext_arr_values
    ON
        ext_arr.field_id = ext_arr_values.field_id
    GROUP BY
        ext_arr.field_id
        , ext_arr.field_name
        , ext_arr.field_type
        , ext_arr.usingPossibleValues
    )
    , udf_lookuplist_item_mapping AS
    ( SELECT
        field_id
        , field_name
        , field_value
        ,field_value_id
    FROM
        ext_arr_values
    )
SELECT
    *
FROM
    udf_lookuplist_item_mapping