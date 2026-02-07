SELECT
    invl.PERSON_CENTER ||'p' || invl.PERSON_ID pid,
    prod.NAME product,
    invl.TOTAL_AMOUNT,
    art.UNSETTLED_AMOUNT not_paid,
    longToDate(inv.TRANS_TIME) sold,
    MIN(longToDate(arm.ENTRY_TIME)) paid,
    p.SEX,
    p.FIRSTNAME,
    p.MIDDLENAME,
    inv.EMPLOYEE_CENTER || 'emp' || inv.EMPLOYEE_ID empid,
    invl.TEXT
FROM
    SATS.CLIPCARDS cc
JOIN SATS.INVOICELINES invl
ON
    invl.CENTER = cc.INVOICELINE_CENTER
    AND invl.ID = cc.INVOICELINE_ID
    AND invl.SUBID = cc.INVOICELINE_SUBID
JOIN SATS.INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN SATS.PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND inv.PAYER_ID = p.id
LEFT JOIN SATS.AR_TRANS art
ON
    art.REF_CENTER = invl.CENTER
    AND art.REF_ID = invl.ID
    AND art.REF_TYPE = 'INVOICE'
LEFT JOIN SATS.ART_MATCH arm
ON
    arm.ART_PAID_CENTER = art.CENTER
    AND arm.ART_PAID_ID = art.ID
    AND arm.ART_PAID_SUBID = art.SUBID
JOIN SATS.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
WHERE
    inv.TRANS_TIME BETWEEN :dateFrom AND :dateTo
	and inv.center in (:scope)
	and cc.CANCELLED = 0 and cc.BLOCKED = 0
GROUP BY
    invl.PERSON_CENTER,
    invl.PERSON_ID,
    prod.NAME ,
    invl.TOTAL_AMOUNT,
    art.UNSETTLED_AMOUNT,
    longToDate(inv.TRANS_TIME) ,
    p.SEX,
    p.FIRSTNAME,
    p.MIDDLENAME,
    inv.EMPLOYEE_CENTER,
    inv.EMPLOYEE_ID ,
    invl.TEXT