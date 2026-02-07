/*
At the moment the credit note amount is just deducted but this might need to be done another way.
According to Nick the credit note information is probabaly not needed at all since the only measuers sales so it might be that it should be removed all together.
The border case are partly credited invoices
*/
SELECT
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID "ChargeID",
    invl.CENTER || 'inv' || invl.ID "TransactionID",
    p.EXTERNAL_ID "PersonID",
    forP.EXTERNAL_ID "ForPersonID",
    longToDate(inv.TRANS_TIME) "ChargeDate",
    (invl.TOTAL_AMOUNT / invl.QUANTITY) - (NVL(cnl.TOTAL_AMOUNT,0)) "ChargeAmount",
    ch.NAME "ChargeType",
    art.STATUS "ChargeStatus",
    '?' "ChargeStatusDate",
    art.DUE_DATE "ChargeDueDate",
    art.TEXT "ChargeDescription",
    'N/A' "ChargeAdvanced",
    inv.CENTER "SiteID",
    '?' "ProductCounter",
    prod.CENTER || 'prod' || prod.ID "ProductID",
    invl.QUANTITY "Quantity",
    'EXERP' "SourceSystem",
    invl.CENTER || 'inv' || invl.ID || 'ln' || invl.SUBID "ExtRef"
FROM
    INVOICES inv
JOIN INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
LEFT JOIN PERSONS forOP
ON
    forOP.CENTER = invl.PERSON_CENTER
    AND forOP.ID = invl.PERSON_ID
LEFT JOIN PERSONS forP
ON
    forP.CENTER = forOP.CURRENT_PERSON_CENTER
    AND forP.ID = forOP.CURRENT_PERSON_ID
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
LEFT JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pac.ACTIVE_AGR_CENTER
    AND pagr.ID = pac.ACTIVE_AGR_ID
    AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN CLEARINGHOUSES ch
ON
    ch.id = pagr.CLEARINGHOUSE
WHERE
    inv.PAYSESSIONID IS NULL