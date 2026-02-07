SELECT
    inv.PAYER_CENTER || 'p' || inv.PAYER_ID     payer_id,
    pp.FULLNAME,
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID for_member,
    pu.FULLNAME,
    exerpro.longToDate(inv.TRANS_TIME)          transaction_time,
    'INVOICE'                                   TYPE,
    c.NAME                                      center_name,
    prod.NAME,
    pg.NAME                                                                                                                                                                                                        product_group_name,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on') PT_TYPE,
    TO_CHAR( SUM(invl.TOTAL_AMOUNT ), 'FM999999999999,9990.09' )                                                                                                                                                                        revenue,
    TO_CHAR( SUM(invl.TOTAL_AMOUNT / (1 + NVL(invl.ORIG_RATE,0))), 'FM999999999999,9990.09' )                                                                                                                                           revenue_excl_vat,
    SUM(invl.QUANTITY)                                                                                                                                                                                                        "count"
FROM
    INVOICELINES invl
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    AND (
        pg.id = 271
        OR pg.PARENT_PRODUCT_GROUP_ID = 271)
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN
    CENTERS c
ON
    c.ID = inv.CENTER
left join PERSONS pp on pp.CENTER = inv.PAYER_CENTER and pp.id = inv.PAYER_ID
left join PERSONS pu on pu.CENTER = invl.PERSON_CENTER and pu.id = invl.PERSON_ID    
WHERE
    prod.PTYPE IN (4,10,12,13)
    /* Who to include */
    AND inv.TRANS_TIME BETWEEN $$fromDate$$ AND (
        $$toDate$$ + (1000 * 60 * 60 * 24)-1)
    AND inv.CENTER IN ($$scope$$)
GROUP BY
    /*inv.PAYER_CENTER,inv.PAYER_ID, */
    c.NAME ,
    prod.NAME ,
    pp.FULLNAME,
    pu.FULLNAME,
    pg.NAME ,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on'),
    inv.PAYER_CENTER || 'p' || inv.PAYER_ID ,
    invl.PERSON_CENTER || 'p' || invl.PERSON_ID ,
    exerpro.longToDate(inv.TRANS_TIME)
UNION
SELECT

    cn.PAYER_CENTER || 'p' || cn.PAYER_ID     payer_id,
    pp.FULLNAME,
    cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID for_member,
    pu.FULLNAME,
    exerpro.longToDate(cn.TRANS_TIME)         transaction_time,
    'CREDIT_NOTE'                             TYPE,
    c.NAME                                    center_name,
    prod.NAME,
    pg.NAME                                                                                                                                                                                                        product_group_name,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on') PT_TYPE,
    TO_CHAR( SUM(-1 * cnl.TOTAL_AMOUNT ), 'FM999999999999,9990.09' )                                                                                                                                                                    date_Revenue,
    TO_CHAR( SUM(-1 * cnl.TOTAL_AMOUNT / (1 + NVL(cnl.ORIG_RATE,0))), 'FM999999999999,9990.09' )                                                                                                                                        revenue_excl_vat,
    SUM(-1 * cnl.QUANTITY)                                                                                                                                                                                                        "count"
FROM
    CREDIT_NOTE_LINES cnl
JOIN
    PRODUCTS prod
ON
    prod.CENTER = cnl.PRODUCTCENTER
    AND prod.ID = cnl.PRODUCTID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    AND (
        pg.id = 271
        OR pg.PARENT_PRODUCT_GROUP_ID = 271)
JOIN
    CREDIT_NOTES cn
ON
    cn.CENTER = cnl.CENTER
    AND cn.ID = cnl.ID
JOIN
    CENTERS c
ON
    c.ID = cn.CENTER
    
left join PERSONS pp on pp.CENTER = cn.PAYER_CENTER and pp.id = cn.PAYER_ID
left join PERSONS pu on pu.CENTER = cnl.PERSON_CENTER and pu.id = cnl.PERSON_ID
    
WHERE
    prod.PTYPE IN (4,10,12,13)
    /* Who to include */
    AND cn.TRANS_TIME BETWEEN $$fromDate$$ AND (
        $$toDate$$ + (1000 * 60 * 60 * 24)-1)
    AND cn.CENTER IN ($$scope$$)
GROUP BY
    cn.PAYER_CENTER || 'p' || cn.PAYER_ID ,
    cnl.PERSON_CENTER || 'p' || cnl.PERSON_ID ,
        pp.FULLNAME,
    pu.FULLNAME,
    exerpro.longToDate(cn.TRANS_TIME) ,
    c.NAME ,
    prod.NAME ,
    pg.NAME ,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on')