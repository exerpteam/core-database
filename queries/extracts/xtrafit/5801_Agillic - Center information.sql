-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.id,
    c.name,
    c.shortname,
    c.address1,
    c.phone_number,
    c.email,
    c.website_url,
    cea1.txt_value AS Gesellschaft,
    iban.txt_value AS IBAN,
    bic.txt_value  AS BIC
FROM
    centers c
LEFT JOIN
    center_ext_attrs cea1
ON
    cea1.center_id = c.id
AND cea1.name = 'C1'
LEFT JOIN
    center_ext_attrs iban
ON
    iban.center_id = c.id
AND iban.name = 'C2'
LEFT JOIN
    center_ext_attrs bic
ON
    bic.center_id = c.id
AND bic.name = 'BIC'