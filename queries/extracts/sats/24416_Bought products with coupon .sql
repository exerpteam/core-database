SELECT
    longToDate(crt.TRANSTIME),
    inv.CENTER || 'inv' || inv.id inv_id,
    inv.PAYER_CENTER || 'p' || inv.PAYER_ID pid,
    inv.TEXT,
    invl.QUANTITY,
    invl.TOTAL_AMOUNT,
    prod.NAME
FROM
    SATS.CASHREGISTERTRANSACTIONS crt
JOIN SATS.INVOICES inv
ON
    inv.CASHREGISTER_CENTER = crt.CENTER
    AND inv.CASHREGISTER_ID = crt.ID
    AND inv.PAYSESSIONID = crt.PAYSESSIONID
JOIN SATS.INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
JOIN SATS.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
WHERE
    crt.CUSTOMERCENTER in (:scope)
    AND crt.TRANSTIME between :startDate and :endDate
    AND EXISTS
    (
        SELECT
            *
        FROM
            SATS.INVOICELINES invl2
        JOIN SATS.PRODUCTS prod2
        ON
            prod2.CENTER = invl2.CENTER
            AND prod2.ID = invl2.PRODUCTID
        WHERE
            prod2.NAME = :couponName
            and invl2.CENTER = inv.CENTER and invl2.ID = inv.ID
    )