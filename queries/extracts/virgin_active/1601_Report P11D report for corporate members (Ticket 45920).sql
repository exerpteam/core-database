SELECT
    'INVOICE'                               TYPE,
    c.NAME                                  club,
    inv.PAYER_CENTER || 'p' || inv.PAYER_ID pid,
    inv.CENTER || 'inv' || inv.ID "Member invoice/credit note id",
    invl.TOTAL_AMOUNT                            MEMBER_AMOUNT_LINE,
    spp.FROM_DATE || ' to ' || spp.TO_DATE period,
    link.PERIOD_CENTER || 'ss' || link.PERIOD_ID Membership_number,
    p.FULLNAME as "Member Name",
    prod.NAME                                    membership_type,
    comp.CENTER || 'p' || comp.ID                company_id,
    comp.LASTNAME                                COMPANY_NAME,
    cinv.CENTER || 'inv' || cinv.ID "Company invoice/credit note id",
    cinvl.TOTAL_AMOUNT COMPANY_AMOUNT_LINE
FROM
    INVOICES inv
JOIN
    PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.INVOICELINE_CENTER = invl.CENTER
    AND link.INVOICELINE_ID = invl.ID
    AND link.INVOICELINE_SUBID = invl.SUBID
join SUBSCRIPTIONPERIODPARTS spp on spp.CENTER = link.PERIOD_CENTER and spp.ID = link.PERIOD_ID and spp.SUBID = link.PERIOD_SUBID    
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN
    INVOICES cinv
ON
    cinv.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND cinv.ID = inv.SPONSOR_INVOICE_ID
JOIN
    PERSONS comp
ON
    comp.CENTER = cinv.PAYER_CENTER
    AND comp.ID = cinv.PAYER_ID
JOIN
    INVOICELINES cinvl
ON
    cinvl.CENTER = cinv.CENTER
    AND cinvl.ID = cinv.ID
    AND cinvl.SUBID = invl.SPONSOR_INVOICE_SUBID
JOIN
    CENTERS c
ON
    c.ID = inv.CENTER
WHERE
    cinv.ENTRY_TIME  BETWEEN dateToLong(TO_CHAR(TRUNC($$from_month$$,'MM'), 'YYYY-MM-dd HH24:MI')) AND (
        dateToLong(TO_CHAR(add_months(TRUNC($$to_month$$,'MM'),1), 'YYYY-MM-dd HH24:MI'))-1)
    AND cinv.CENTER IN ($$scope$$)
UNION ALL
SELECT
    'CREDIT_NOTE' ,
    c.NAME ,
    cn.PAYER_CENTER || 'p' || cn.PAYER_ID ,
    cn.CENTER || 'cn' ||      cn.ID ,
    cnl.TOTAL_AMOUNT ,
    spp.FROM_DATE || ' to ' || spp.TO_DATE range,
    link.PERIOD_CENTER || 'ss' || link.PERIOD_ID ,
    p.FULLNAME,
    prod.NAME ,
    comp.CENTER || 'p' || comp.ID ,
    comp.LASTNAME ,
    ccnl.CENTER || 'cn' || ccnl.ID ,
    ccnl.TOTAL_AMOUNT
FROM
    CREDIT_NOTES cn
JOIN
    CREDIT_NOTE_LINES cnl
ON
    cnl.CENTER = cn.CENTER
    AND cnl.ID = cn.ID
JOIN
    INVOICES inv
ON
    inv.CENTER = cn.INVOICE_CENTER
    AND inv.ID = cn.INVOICE_ID
JOIN
    PERSONS p
ON
    p.CENTER = cn.PAYER_CENTER
    AND p.ID = cn.PAYER_ID
JOIN
    INVOICELINES invl
ON
    invl.CENTER = cnl.INVOICELINE_CENTER
    AND invl.ID = cnl.INVOICELINE_ID
    AND invl.SUBID = cnl.INVOICELINE_SUBID
JOIN
    SPP_INVOICELINES_LINK link
ON
    link.INVOICELINE_CENTER = invl.CENTER
    AND link.INVOICELINE_ID = invl.ID
    AND link.INVOICELINE_SUBID = invl.SUBID
join SUBSCRIPTIONPERIODPARTS spp on spp.CENTER = link.PERIOD_CENTER and spp.ID = link.PERIOD_ID and spp.SUBID = link.PERIOD_SUBID        
JOIN
    PRODUCTS prod
ON
    prod.CENTER = cnl.PRODUCTCENTER
    AND prod.ID = cnl.PRODUCTID
JOIN
    INVOICES cinv
ON
    cinv.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND cinv.ID = inv.SPONSOR_INVOICE_ID
JOIN
    INVOICELINES cinvl
ON
    cinvl.CENTER = cinv.CENTER
    AND cinvl.ID = cinv.ID
    AND cinvl.SUBID = invl.SPONSOR_INVOICE_SUBID
LEFT JOIN
    CREDIT_NOTE_LINES ccnl
ON
    ccnl.INVOICELINE_CENTER = cinvl.CENTER
    AND ccnl.INVOICELINE_id = cinvl.ID
    AND ccnl.INVOICELINE_SUBID = cinvl.SUBID
JOIN
    PERSONS comp
ON
    comp.CENTER = cinv.PAYER_CENTER
    AND comp.ID = cinv.PAYER_ID
JOIN
    CENTERS c
ON
    c.ID = inv.CENTER
WHERE
    cn.ENTRY_TIME BETWEEN dateToLong(TO_CHAR(TRUNC($$from_month$$,'MM'), 'YYYY-MM-dd HH24:MI')) AND (
        dateToLong(TO_CHAR(add_months(TRUNC($$to_month$$,'MM'),1), 'YYYY-MM-dd HH24:MI'))-1)
    AND cn.CENTER IN ($$scope$$)