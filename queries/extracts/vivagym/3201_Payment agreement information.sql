SELECT
    paa.*
FROM
    PAYMENT_AGREEMENTS paa
WHERE
paa.active = true
AND paa.creditor_id = 'Adyen'