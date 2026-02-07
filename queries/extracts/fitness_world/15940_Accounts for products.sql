-- This is the version from 2026-02-05
-- Ticket 44331
SELECT DISTINCT
	
    prod.NAME,
	CASE prod.PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata' END P_TYPE,
    prod.GLOBALID,
    pac.NAME,
    sales_acc.NAME sales_acc_NAME,
    sales_acc.EXTERNAL_ID sales_acc_EXTERNAL_ID,
    sales_acc_vat.NAME sales_acc_vat_NAME,
    sales_acc_vat.EXTERNAL_ID sales_acc_vat_EXTERNAL_ID,
    expenses_acc.NAME expenses_acc_NAME,
    expenses_acc.EXTERNAL_ID expenses_acc_EXTERNAL_ID,
    expenses_acc_vat.NAME expenses_acc_vat_NAME,
    expenses_acc_vat.EXTERNAL_ID expenses_acc_vat_EXTERNAL_ID,
    refund_acc.NAME refund_acc_NAME,
    refund_acc.EXTERNAL_ID refund_acc_EXTERNAL_ID,
    refund_acc_vat.NAME refund_acc_vat_NAME,
    refund_acc_vat.EXTERNAL_ID refund_acc_vat_EXTERNAL_ID,
    write_off_acc.NAME write_off_acc_NAME,
    write_off_acc.EXTERNAL_ID write_off_acc_EXTERNAL_ID,
    write_off_acc_vat.NAME write_off_acc_vat_NAME,
    write_off_acc_vat.EXTERNAL_ID write_off_acc_vat_EXTERNAL_ID
FROM
    PRODUCTS prod
JOIN CENTERS c
ON
    c.ID = prod.CENTER
JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
    pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
LEFT JOIN ACCOUNTS sales_acc
ON
    sales_acc.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND sales_acc.CENTER = c.ID
LEFT JOIN ACCOUNT_VAT_TYPE_LINK sales_acc_link
ON
    sales_acc.ACCOUNT_VAT_TYPE_GROUP_ID = sales_acc_link.ACCOUNT_VAT_TYPE_GROUP_ID
LEFT JOIN VAT_TYPES sales_acc_vat
ON
    sales_acc_vat.CENTER = sales_acc_link.VAT_TYPE_CENTER
    AND sales_acc_vat.ID = sales_acc_link.VAT_TYPE_ID
LEFT JOIN ACCOUNTS expenses_acc
ON
    expenses_acc.GLOBALID = pac.EXPENSES_ACCOUNT_GLOBALID
    AND expenses_acc.CENTER = c.ID
LEFT JOIN ACCOUNT_VAT_TYPE_LINK expenses_acc_link
ON
    expenses_acc.ACCOUNT_VAT_TYPE_GROUP_ID = expenses_acc_link.ACCOUNT_VAT_TYPE_GROUP_ID
LEFT JOIN VAT_TYPES expenses_acc_vat
ON
    expenses_acc_vat.CENTER = expenses_acc_link.VAT_TYPE_CENTER
    AND expenses_acc_vat.ID = expenses_acc_link.VAT_TYPE_ID
LEFT JOIN ACCOUNTS refund_acc
ON
    refund_acc.GLOBALID = pac.REFUND_ACCOUNT_GLOBALID
    AND refund_acc.CENTER = c.ID
LEFT JOIN ACCOUNT_VAT_TYPE_LINK refund_acc_link
ON
    refund_acc.ACCOUNT_VAT_TYPE_GROUP_ID = refund_acc_link.ACCOUNT_VAT_TYPE_GROUP_ID
LEFT JOIN VAT_TYPES refund_acc_vat
ON
    refund_acc_vat.CENTER = refund_acc_link.VAT_TYPE_CENTER
    AND refund_acc_vat.ID = refund_acc_link.VAT_TYPE_ID
LEFT JOIN ACCOUNTS write_off_acc
ON
    write_off_acc.GLOBALID = pac.WRITE_OFF_ACCOUNT_GLOBALID
    AND write_off_acc.CENTER = c.ID
LEFT JOIN ACCOUNT_VAT_TYPE_LINK write_off_acc_link
ON
    write_off_acc.ACCOUNT_VAT_TYPE_GROUP_ID = write_off_acc_link.ACCOUNT_VAT_TYPE_GROUP_ID
LEFT JOIN VAT_TYPES write_off_acc_vat
ON
    write_off_acc_vat.CENTER = write_off_acc_link.VAT_TYPE_CENTER
    AND write_off_acc_vat.ID = write_off_acc_link.VAT_TYPE_ID
WHERE
    prod.BLOCKED in (:blocked)
