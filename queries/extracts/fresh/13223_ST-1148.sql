SELECT DISTINCT
    pp.CENTER || 'p' || pp.ID payer_id,
    pp.FULLNAME               payer_name,
    pc.CENTER || 'p' || pc.ID customer_id,
    pc.FULLNAME               customer_name,
    prod.NAME,
	prod.COST_PRICE,
    pg.NAME  PRODUCT_GROUP,  
    longToDate(inv.TRANS_TIME) time_of_purchase,
    invl.QUANTITY,
    invl.TOTAL_AMOUNT,
    invl.CENTER,
    invl.ID,
    invl.SUBID
FROM
    INVOICELINES invl
JOIN
    INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
LEFT JOIN
    PERSONS pp
ON
    pp.CENTER = inv.PAYER_CENTER
    AND pp.ID = inv.PAYER_ID
LEFT JOIN
    PERSONS pc
ON
    pc.CENTER = invl.PERSON_CENTER
    AND pc.ID = invl.PERSON_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
JOIN
    PRODUCT_GROUP pg
ON
    pg.id = prod.PRIMARY_PRODUCT_GROUP_ID
WHERE 
    ((
            $$type$$ = 'PRODUCT'
            AND prod.GLOBALID IN ($$GLOBAL_ID$$))
        OR (
            $$type$$ = 'GROUP'
            AND pg.name IN ($$GROUP$$)))
    AND  inv.center IN ($$scope$$)
    AND inv.TRANS_TIME BETWEEN $$time_from$$ AND $$time_to$$