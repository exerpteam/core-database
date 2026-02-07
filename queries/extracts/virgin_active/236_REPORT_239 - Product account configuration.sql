SELECT
    prod.CENTER,
    prod.ID,
    prod.NAME                                                                                                                                                                                                        PRODUCT_NAME,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') TYPE,
    prod.PRICE,
    ac.NAME                                                                         SALES_ACCOUNT_NAME,
    ac.EXTERNAL_ID                                                                  SALES_ACCOUNT_EXTERNAL_ID,
    ac.BLOCKED                                                                      SALES_ACCOUNT_BLOCKED,
    DECODE(ac.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED')     SALES_ACCOUNT_TYPE,
    ac_vat.NAME                                                                     SALES_ACCOUNT_VAT_NAME,
    ac_vat.EXTERNAL_ID                                                                     SALES_ACCOUNT_VAT_EXT_ID,
    ac_vat.BLOCKED                                                                  SALES_ACCOUNT_VAT_BLOCKED,
    DECODE(ac_vat.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED') SALES_ACCOUNT_VAT_TYPE,
    ae.NAME                                                                         EXPENSES_ACCOUNT_NAME,
    ae.EXTERNAL_ID                                                                  EXPENSES_ACCOUNT_EXTERNAL_ID,
    ae.BLOCKED                                                                      EXPENSES_ACCOUNT_BLOCKED,
    DECODE(ae.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED')     EXPENSES_ACCOUNT_TYPE,
    ae_vat.NAME                                                                     EXPENSES_ACCOUNT_VAT_NAME,
    ae_vat.EXTERNAL_ID                                                                     EXPENSES_ACCOUNT_VAT_EXT_ID,
    ae_vat.BLOCKED                                                                  EXPENSES_ACCOUNT_VAT_BLOCKED,
    DECODE(ae_vat.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED') EXPENSES_ACCOUNT_VAT_TYPE,
    ar.NAME                                                                         REFUND_ACCOUNT_NAME,
    ar.EXTERNAL_ID                                                                  REFUND_ACCOUNT_EXTERNAL_ID,
    ar.BLOCKED                                                                      REFUND_ACCOUNT_BLOCKED,
    DECODE(ar.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED')     REFUND_ACCOUNT_TYPE,
    ar_vat.NAME                                                                     REFUND_ACCOUNT_VAT_NAME,
    ar_vat.EXTERNAL_ID                                                                     REFUND_ACCOUNT_VAT_EXT_ID,
    ar_vat.BLOCKED                                                                  REFUND_ACCOUNT_VAT_BLOCKED,
    DECODE(ar_vat.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED') REFUND_ACCOUNT_VAT_TYPE,
    aw.NAME                                                                         WRITE_OFF_ACCOUNT_NAME,
    aw.EXTERNAL_ID                                                                  WRITE_OFF_ACCOUNT_EXTERNAL_ID,
    aw.BLOCKED                                                                      WRITE_OFF_ACCOUNT_BLOCKED,
    DECODE(aw.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED')     WRITE_OFF_ACCOUNT_TYPE,
    aw_vat.NAME                                                                     WRITE_OFF_ACCOUNT_VAT_NAME,
    aw_vat.EXTERNAL_ID                                                                     WRITE_OFF_ACCOUNT_VAT_EXT_ID,
    aw_vat.BLOCKED                                                                  WRITE_OFF_ACCOUNT_VAT_BLOCKED,
    DECODE(aw_vat.ATYPE,1,'Asset',2,'Liability',3,'Sales',4,'Purchase','UNDEFINED') WRITE_OFF_ACCOUNT_VAT_TYPE
FROM
    PRODUCTS prod
LEFT JOIN
    PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
    pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN
    ACCOUNTS ac
ON
    ac.CENTER = prod.CENTER
    AND ac.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
LEFT JOIN
    ACCOUNTS ac_vat
ON
    ac_vat.CENTER = ac.VAT_CENTER
    AND ac_vat.ID = ac.VAT_ID
LEFT JOIN
    ACCOUNTS ae
ON
    ae.CENTER = prod.CENTER
    AND ae.GLOBALID = pac.EXPENSES_ACCOUNT_GLOBALID
LEFT JOIN
    ACCOUNTS ae_vat
ON
    ae_vat.CENTER = ae.VAT_CENTER
    AND ae_vat.ID = ae.VAT_ID
LEFT JOIN
    ACCOUNTS ar
ON
    ar.CENTER = prod.CENTER
    AND ar.GLOBALID = pac.REFUND_ACCOUNT_GLOBALID
LEFT JOIN
    ACCOUNTS ar_vat
ON
    ar_vat.CENTER = ar.VAT_CENTER
    AND ar_vat.ID = ar.VAT_ID
LEFT JOIN
    ACCOUNTS aw
ON
    aw.CENTER = prod.CENTER
    AND aw.GLOBALID = pac.WRITE_OFF_ACCOUNT_GLOBALID
LEFT JOIN
    ACCOUNTS aw_vat
ON
    aw_vat.CENTER = aw.VAT_CENTER
    AND aw_vat.ID = aw.VAT_ID
WHERE
    prod.BLOCKED = 0
    AND prod.center IN (:scope)