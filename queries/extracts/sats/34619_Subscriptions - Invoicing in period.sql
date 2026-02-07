SELECT
    sales.CENTER,
    c.SHORTNAME center_name,    
    SALES_TYPE,
    PRODUCT_NAME,
    PRODUCT_TYPE,
    PERSON_CENTER || 'p' || PERSON_ID memberId,
    CASE
        WHEN payer.SEX = 'C'
        THEN 'YES'
        ELSE 'NO'
    END is_Company,
    CASE
        WHEN sales.payer_center || 'p' || sales.payer_id <> sales.PERSON_CENTER || 'p' || sales.PERSON_ID  AND payer.SEX <> 'C'
        THEN 'YES'
        ELSE 'NO'
    END is_Paid_by_other,
    DECODE(spp.SPP_TYPE, 1, 'NORMAL', 2, 'FREEZE', 3, 'FREE', 7, 'FREEZE', 8, 'UPFRONT') PERIOD_TYPE, 
    TO_CHAR(spp.FROM_DATE,'YYYY-MM-DD') PERIOD_FROM,
    TO_CHAR(spp.TO_DATE, 'YYYY-MM-DD') PERIOD_TO,
    act.AMOUNT,
    --TO_CHAR(exerpro.longtodateTZ(sales.TRANS_TIME, 'Europe/Helsinki'), 'YYYY-MM-DD') book_date,
    TO_CHAR(agt.BOOK_DATE, 'YYYY-MM-DD') agresso_date,
    agt.DEBIT_ACCOUNT_EXTERNAL_ID agresso_debit,
    agt.CREDIT_ACCOUNT_EXTERNAL_ID agresso_credit,
    agt.CENTER || 'agt' || agt.ID agresso_trans_id,
    exerpro.longtodateTZ(sales.ENTRY_TIME, 'Europe/Helsinki') entry_time
FROM
    (
        SELECT
            il.CENTER,
            il.ID,
            il.SUBID SUB_ID,
            'INVOICE' SALES_TYPE,
            il.TEXT,
            il.PERSON_CENTER,
            il.PERSON_ID,
            i.EMPLOYEE_CENTER,
            i.EMPLOYEE_ID,
            i.ENTRY_TIME,
            i.TRANS_TIME,
            i.CASHREGISTER_CENTER,
            i.CASHREGISTER_ID,
            i.PAYSESSIONID,
            i.PAYER_CENTER,
            i.PAYER_ID,
            prod.CENTER PRODUCT_CENTER,
            prod.ID PRODUCT_ID,
            prod.NAME PRODUCT_NAME,
            prod.PTYPE,
            DECODE(prod.PTYPE, 1, 'RETAIL', 2, 'SERVICE', 4, 'CLIPCARD', 5, 'JOINING_FEE', 6, 'TRANSFER_FEE', 7,
            'FREEZE_PERIOD', 8, 'GIFTCARD', 9, 'FREE_GIFTCARD', 10, 'SUBS_PERIOD', 12, 'SUBS_PRORATA', 13, 'ADDON', 14, 'ACCESS')
            product_type,
            pg.NAME PRODUCT_GROUP_NAME,
            il.QUANTITY,
            ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) net_amount,
            ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),2) Vat_amount,
            ROUND(il.TOTAL_AMOUNT, 2) total_amount,
            il.ACCOUNT_TRANS_CENTER,
            il.ACCOUNT_TRANS_ID,
            il.ACCOUNT_TRANS_SUBID
        FROM
            INVOICELINES il
        JOIN
            INVOICES i
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        UNION ALL
        SELECT
            cl.CENTER,
            cl.ID,
            cl.SUBID SUB_ID,
            'CREDIT_NOTE' SALES_TYPE,
            cl.TEXT,
            cl.PERSON_CENTER,
            cl.PERSON_ID,
            c.EMPLOYEE_CENTER,
            c.EMPLOYEE_ID,
            c.ENTRY_TIME,
            c.TRANS_TIME,
            c.CASHREGISTER_CENTER,
            c.CASHREGISTER_ID,
            c.PAYSESSIONID,
            c.PAYER_CENTER,
            c.PAYER_ID,
            prod.CENTER PRODUCT_CENTER,
            prod.ID PRODUCT_ID,
            prod.NAME PRODUCT_NAME,
            prod.PTYPE,
            DECODE(prod.PTYPE, 1, 'RETAIL', 2, 'SERVICE', 4, 'CLIPCARD', 5, 'JOINING_FEE', 6, 'TRANSFER_FEE', 7,
            'FREEZE_PERIOD', 8, 'GIFTCARD', 9, 'FREE_GIFTCARD', 10, 'SUBS_PERIOD', 12, 'SUBS_PRORATA', 13, 'ADDON', 14, 'ACCESS')
            product_type,
            pg.NAME PRODUCT_GROUP_NAME,
            -cl.QUANTITY,
            -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 2) excluding_Vat,
            -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2) VAT,
            -ROUND(cl.TOTAL_AMOUNT, 2) total,
            cl.ACCOUNT_TRANS_CENTER,
            cl.ACCOUNT_TRANS_ID,
            cl.ACCOUNT_TRANS_SUBID
        FROM
            CREDIT_NOTES c
        JOIN
            CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID) sales
JOIN
    CENTERS c
ON
    c.ID = sales.CENTER
JOIN
    PERSONS payer
ON
    payer.CENTER = sales.PAYER_CENTER
    AND payer.ID = sales.PAYER_ID
LEFT JOIN
    ACCOUNT_TRANS act
ON
    sales.ACCOUNT_TRANS_CENTER = act.CENTER
    AND sales.ACCOUNT_TRANS_ID = act.ID
    AND sales.ACCOUNT_TRANS_SUBID = act.SUBID
LEFT JOIN
    AGGREGATED_TRANSACTIONS agt
ON
    agt.CENTER = act.AGGREGATED_TRANSACTION_CENTER
    AND agt.ID = act.AGGREGATED_TRANSACTION_ID
LEFT JOIN
    SPP_INVOICELINES_LINK spl
ON
    spl.INVOICELINE_CENTER = sales.CENTER
    AND spl.INVOICELINE_ID = sales.ID
    AND spl.INVOICELINE_SUBID = sales.SUB_ID
    AND sales.SALES_TYPE <> 'CREDIT_NOTE'
LEFT JOIN
    SATS.SUBSCRIPTIONPERIODPARTS spp
ON
    spl.PERIOD_CENTER = spp.CENTER
    AND spl.PERIOD_ID = spp.ID
    AND spl.PERIOD_SUBID = spp.SUBID
WHERE
    sales.center in ($$Scope$$)
    AND sales.TRANS_TIME >= $$FromDate$$ 
    AND sales.TRANS_TIME < $$ToDate$$ + (1000*60*60*24)
    AND product_type IN ( 'FREEZE_PERIOD', 'SUBS_PERIOD',
                         'SUBS_PRORATA' )