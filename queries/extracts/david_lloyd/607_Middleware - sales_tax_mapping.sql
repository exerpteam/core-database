-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    DISTINCT globalid AS sales_tax_name_exerp
    , NULL            AS sales_tax_id
    , NULL            AS sales_tax_description
    , NULL               sales_tax_amount
    ,ROUND(rate, 2)   AS sales_tax_percentage
FROM
    vat_types