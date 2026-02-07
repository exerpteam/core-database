-- This is the version from 2026-02-05
-- Ticket 35267
SELECT
    NVL2(invl.SPONSOR_INVOICE_SUBID,'TRUE','FALSE') sponsored_line,
    longToDate(cn.ENTRY_TIME) ENTRY_TIME,
    cn.TEXT cn_text,
    cnl.TEXT line_text,
    cnl.TOTAL_AMOUNT,
    cn.CENTER || 'cred' || cn.ID credit_id,
    cn.INVOICE_CENTER || 'inv' || cn.INVOICE_ID inv_id,
    emp.CENTER || 'emp' || emp.ID emp,
    pEmp.FIRSTNAME || ' ' || pEmp.LASTNAME emp_name,
    p.CENTER || 'p' || p.ID pid,
    p.FIRSTNAME || ' ' || p.LASTNAME p_name,
    DECODE(prod.PTYPE , 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata') prod_type,
    prod.NAME
FROM
    FW.CREDIT_NOTES cn
JOIN FW.CREDIT_NOTE_LINES cnl
ON
    cnl.CENTER = cn.CENTER
    AND cnl.ID = cn.ID
LEFT JOIN FW.INVOICES inv
ON
    inv.CENTER = cn.INVOICE_CENTER
    AND inv.ID = cn.INVOICE_ID
LEFT JOIN FW.INVOICELINES invl
ON
    invl.CENTER = cnl.INVOICELINE_CENTER
    AND invl.ID = cnl.INVOICELINE_ID
    AND invl.SUBID = cnl.INVOICELINE_SUBID
JOIN FW.PRODUCTS prod
ON
    prod.CENTER = cnl.PRODUCTCENTER
    AND prod.ID = cnl.PRODUCTID
JOIN FW.EMPLOYEES emp
ON
    emp.CENTER = cn.EMPLOYEE_CENTER
    AND emp.ID = cn.EMPLOYEE_ID
JOIN FW.PERSONS pEmp
ON
    pEmp.CENTER = emp.PERSONCENTER
    AND pEmp.ID = emp.PERSONID
LEFT JOIN FW.PERSONS p
ON
    p.CENTER = cn.PAYER_CENTER
    AND p.ID = cn.PAYER_ID
WHERE
    NVL2(invl.SPONSOR_INVOICE_SUBID,1,0) in (:sponsored)
    AND cn.TRANS_TIME BETWEEN :timeFrom AND :timeTo
    AND cn.CENTER IN (:scope)