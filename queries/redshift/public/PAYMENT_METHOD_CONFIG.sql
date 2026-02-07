SELECT DISTINCT
    id||'_'||(xpath('//attribute/@id',xml_element))[1]                   AS "ID",
    CAST((xpath('//attribute/@id',xml_element))[1] AS text)         AS "PAYMENT_METHOD_ID",
    CAST((xpath('//attribute/@name',xml_element))[1] AS text)            AS "NAME",
    CAST((xpath('//attribute/@globalAccountId',xml_element))[1] AS text) AS "ACCOUNT_ID",
    CAST((xpath('//attribute/@blocked',xml_element))[1] AS text)         AS "BLOCKED",
    case scope_type when 'C' then 'CENTER' when 'A' then 'AREA' when 'T' then 'TREE' when 'G' then 'GLOBAL' end as "SCOPE_TYPE",
    scope_id as "SCOPE_ID"
FROM
    (
        SELECT
            s.id,
            s.scope_type,
            s.scope_id,
            unnest(xpath('//attribute',xmlparse(document convert_from(s.mimevalue, 'UTF-8')) )) AS
            xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'PaymentMethodsConfig'
            and s.mimetype = 'text/xml') t