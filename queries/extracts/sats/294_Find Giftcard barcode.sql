SELECT
    gc.CENTER,
    gc.ID,
    gc.STATE,
    gc.AMOUNT,
    gc.PRODUCT_CENTER,
    gc.PRODUCT_ID,
    e.IDENTITY,
    gc.INVOICELINE_CENTER,
    gc.INVOICELINE_ID,
    gc.INVOICELINE_SUBID,
    gc.EXPIRATIONDATE,
    LongToDate(gc.USE_TIME)
FROM
    GIFT_CARDS gc
JOIN "ENTITYIDENTIFIERS" E
ON
    E.ref_center = gc.center
    AND E.ref_id= gc.id
    AND E."IDMETHOD" = 1
    AND E."REF_TYPE" = 5
WHERE
    gc.center = :centernr

