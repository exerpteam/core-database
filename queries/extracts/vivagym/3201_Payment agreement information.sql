-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    paa.*
FROM
    PAYMENT_AGREEMENTS paa
WHERE
paa.active = true
AND paa.creditor_id = 'Adyen'