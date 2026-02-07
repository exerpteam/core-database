SELECT
    crt.center||'crt'||crt.id||'id'||crt.subid AS "ID",
    i.center||'inv'||i.id                      AS "SALE_ID",
    crt.config_payment_method_id               AS "PAYMENT_METHOD_ID",
    ROUND(crt.amount,2)                        AS "AMOUNT",
    i.entry_time                               AS "ETS"
FROM
    invoices i
JOIN
    cashregistertransactions crt
ON
    crt.paysessionid = i.paysessionid
WHERE
    crt.config_payment_method_id IS NOT NULL
