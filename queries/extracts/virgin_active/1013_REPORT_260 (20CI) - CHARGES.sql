SELECT
    inv.CENTER || 'inv' || inv.ID PAYMENTID,
    inv.CENTER SiteID,
    invl.SUBID invoice_line,
    nvl2(art.CENTER,art.DUE_DATE,longToDateC(crt.TRANSTIME,inv.center)) ChargeDueDate,
    inv.TRANS_TIME ChargeStatusDate,
    SUBSTR(inv.TEXT, 1, 250) ChargeDescription,
    payerCurrent.EXTERNAL_ID PersonID,
    paidCurrent.EXTERNAL_ID ForPersonID,
    invl.QUANTITY,
    TO_CHAR(invl.TOTAL_AMOUNT ,'FM99999999999999999990.00') TOTAL_AMOUNT,
    prod.NAME PROD_NAME,
    prod.CENTER || 'prod' || prod.ID PROD_ID
FROM
    INVOICES inv
LEFT JOIN AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = inv.CENTER
    AND art.REF_ID = inv.ID
LEFT JOIN CASHREGISTERTRANSACTIONS crt
ON
    crt.PAYSESSIONID = inv.PAYSESSIONID
    AND crt.CRCENTER = inv.CASHREGISTER_CENTER
    AND crt.CRID = inv.CASHREGISTER_ID
JOIN INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
left JOIN PERSONS payerOld
ON
    payerOld.CENTER = inv.PAYER_CENTER
    AND payerOld.ID = inv.PAYER_ID
left JOIN PERSONS payerCurrent
ON
    payerCurrent.CENTER = payerOld.CURRENT_PERSON_CENTER
    AND payerCurrent.ID = payerOld.CURRENT_PERSON_ID
left JOIN PERSONS paidOld
ON
    paidOld.CENTER = invl.PERSON_CENTER
    AND paidOld.ID = invl.PERSON_ID
left JOIN PERSONS paidCurrent
ON
    paidCurrent .CENTER = paidOld.CURRENT_PERSON_CENTER
    AND paidCurrent .ID = paidOld.CURRENT_PERSON_ID
where inv.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')