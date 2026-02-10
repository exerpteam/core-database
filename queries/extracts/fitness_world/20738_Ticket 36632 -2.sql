-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER ||'p' || p.ID pid,
    p.FIRSTNAME,
    p.LASTNAME,
    p.SSN,
    invl.TEXT,
    pold.CENTER || 'p' || pold.ID oldPerson,
    ceil(SUM(months_between(spp.TO_DATE+1,spp.FROM_DATE))) months,
    prod.NAME
FROM
    FW.INVOICES inv
JOIN FW.INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.id
JOIN FW.INVOICES invs
ON
    invs.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND invs.ID = inv.SPONSOR_INVOICE_ID
JOIN FW.INVOICELINES invls
ON
    invls.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND invls.ID = inv.SPONSOR_INVOICE_ID
    AND invls.SUBID = invl.SPONSOR_INVOICE_SUBID
JOIN FW.PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN FW.SPP_INVOICELINES_LINK link
ON
    link.INVOICELINE_CENTER = invl.CENTER
    AND link.INVOICELINE_ID = invl.ID
    AND link.INVOICELINE_SUBID = invl.SUBID
JOIN FW.SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = link.PERIOD_CENTER
    AND spp.ID = link.PERIOD_ID
    AND spp.SUBID = link.PERIOD_SUBID
JOIN FW.SUBSCRIPTIONS s
ON
    s.CENTER = spp.CENTER
    AND s.ID = spp.ID
JOIN FW.PERSONS pold
ON
    pold.CENTER = s.OWNER_CENTER
    AND pold.ID = s.OWNER_ID
JOIN FW.PERSONS p
ON
    p.CENTER = pold.CURRENT_PERSON_CENTER
    AND p.ID = pold.CURRENT_PERSON_ID
WHERE
    invs.PAYER_CENTER = 116
    AND invs.PAYER_ID = 16122
    AND spp.SPP_STATE = 1
    AND
    (
        spp.FROM_DATE BETWEEN to_date('2014-01-01','yyyy-MM-dd') AND to_date('2014-12-31','yyyy-MM-dd')
    )
    AND prod.NAME = 'Firma - Betalingsservice'
GROUP BY
    p.CENTER,
    p.ID ,
    p.FIRSTNAME,
    p.LASTNAME,
    p.SSN,
    invl.TEXT,
    pold.CENTER,
    pold.ID,
    prod.NAME