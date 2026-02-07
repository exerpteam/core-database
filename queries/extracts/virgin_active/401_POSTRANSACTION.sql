/*
At the moment the credit note amount is just deducted but this might need to be done another way.
According to Nick the credit note information is probabaly not needed at all since the only measuers sales so it might be that it should be removed all together.
The border case are partly credited invoices
*/
SELECT
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID POSTRANSACTIONID,
    p.EXTERNAL_ID "PERSONID",
    prod.CENTER || 'prod' || prod.ID "PRODUCTID",
    inv.CENTER || 'inv' || inv.ID "POSRECEIPTID",
    prod.NAME "STOCKITEMNAME",
    invl.QUANTITY "QUANTITY",
    (invl.TOTAL_AMOUNT / invl.QUANTITY) - (NVL(cnl.TOTAL_AMOUNT,0)) AMOUNT ,
    invl.PRODUCT_NORMAL_PRICE - (invl.TOTAL_AMOUNT / invl.QUANTITY) "DISCOUNTAMOUNT",
    longToDate(inv.TRANS_TIME) "CREATEDDATE",
    'EXERP' "SOURCESYSTEM",
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID "EXTREF"
FROM
    INVOICES inv
JOIN INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
LEFT JOIN CREDIT_NOTE_LINES cnl
ON
    cnl.INVOICELINE_CENTER = invl.CENTER
    AND cnl.INVOICELINE_ID = invl.ID
    AND cnl.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN PERSONS op
ON
    op.CENTER = inv.PAYER_CENTER
    AND op.ID = inv.PAYER_ID
LEFT JOIN PERSONS p
ON
    p.CENTER = op.CURRENT_PERSON_CENTER
    AND p.ID = op.CURRENT_PERSON_ID
LEFT JOIN AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
WHERE
    inv.PAYSESSIONID IS NOT NULL