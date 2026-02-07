-- This is the version from 2026-02-05
--  
WITH params AS (
    SELECT
        $$From_Date$$ AS FromDate,
        ($$To_Date$$ + INTERVAL '86400' * 1000 - 1) AS ToDate
)
SELECT
    c.ID, 
    productGroup.NAME product_group_name,
    p.CENTER || 'p' || p.ID payer_id,
    p.FIRSTNAME || ' ' || p.LASTNAME payer_name,
    prod.GLOBALID product,
    prod.name AS product_name,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') product_type,
    SUM (
        CASE
            WHEN invl.SPONSOR_INVOICE_SUBID IS NULL
            THEN 1 * invl.QUANTITY
            ELSE 0
        END )                                                                                    AS SOLD_UNITS,
    REPLACE('' || prod.PRICE, '.', ',')                                                          AS NORMAL_UNIT_PRICE,
    ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT/ (1 + invl.RATE)))),2) AS AMOUNT_EXCL_VAT,
    ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT/ (1 + invl.RATE))),2)                       AS VAT_AMOUNT,
    ROUND(SUM(invl.TOTAL_AMOUNT),2)                                                              AS AMOUNT_INCL_VAT,
    inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID                                                  AS staff,
    staffp.fullname                                                                              AS staff_name,
    to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') as "Invoice Date",
    to_char(longtodate(inv.TRANS_TIME),'HH24:MI') as "Invoice Time",
    cr.NAME  as CashRegister
FROM
    FW.INVOICELINES invl
CROSS JOIN
    params
JOIN FW.INVOICES inv ON
    invl.CENTER = inv.CENTER
    AND invl.id = inv.id
LEFT JOIN FW.PERSONS p
ON
    p.CENTER = inv.PAYER_CENTER
    AND p.ID = inv.PAYER_ID
JOIN FW.CENTERS c
ON
    c.id = invl.CENTER
JOIN FW.PRODUCTS prod
ON
    prod.ID = invl.PRODUCTID
    AND prod.CENTER = invl.PRODUCTCENTER
JOIN FW.PRODUCT_GROUP productGroup
ON
    prod.PRIMARY_PRODUCT_GROUP_ID = productGroup.id
LEFT JOIN FW.employees staff
ON
    inv.EMPLOYEE_CENTER = staff.center
    AND inv.EMPLOYEE_ID = staff.id
LEFT JOIN FW.persons staffp
ON
    staff.personcenter = staffp.center
    AND staff.personid = staffp.id
LEFT JOIN CASHREGISTERS cr
ON 
    inv.CASHREGISTER_CENTER = cr.CENTER
    AND inv.CASHREGISTER_ID = cr.ID
WHERE
    inv.TRANS_TIME >= params.FromDate
    AND inv.TRANS_TIME <= params.ToDate
    AND inv.center IN ($$Scope$$)
    AND NOT EXISTS
    (
        SELECT
            *
        FROM
            FW.CREDIT_NOTE_LINES cnl
        WHERE
            cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.id
            AND cnl.INVOICELINE_SUBID = invl.SUBID
			    )
    AND prod.PTYPE = 2 -- RETAIL PRODUCTS
	AND prod.GLOBALID = 'SERVICE_FREEZE_TYPE_1_FEE'	
GROUP BY
	c.ID,
    prod.name,
    prod.GLOBALID,
    REPLACE('' || prod.PRICE, '.', ','),
    inv.EMPLOYEE_CENTER,
    inv.EMPLOYEE_ID,
    staffp.fullname,
    productGroup.NAME,
    p.CENTER,
    p.ID,
    payer_id,
    p.FIRSTNAME,
    p.LASTNAME,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata'),
     to_char(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') ,
    to_char(longtodate(inv.TRANS_TIME),'HH24:MI'),
    cr.NAME
ORDER BY
    prod.GLOBALID
