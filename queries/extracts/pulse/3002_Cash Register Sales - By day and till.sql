SELECT
    sales_club,
	dato,
    crId cashRegister,
    pname,
    vat_rate,
    ROUND(SUM(excluding_Vat), 2) excl_vat,
    ROUND(SUM(included_Vat), 2) incl_vat,
    ROUND(SUM(total_amount), 2) tot_amount
FROM
    (
        SELECT
            i.center sales_center,
            club.SHORTNAME sales_club,
            cr.CENTER crCenter,
            cr.id crId,
            TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME pname,
            ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),4) excluding_Vat,
            ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),4) included_Vat,
            ROUND(il.TOTAL_AMOUNT, 4) total_Amount,
            il.RATE vat_rate,
            i.EMPLOYEE_CENTER || 'emp' || i.EMPLOYEE_ID emp_id
        FROM
            INVOICES i
        JOIN INVOICELINES il
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        JOIN CENTERS club
        ON
            i.center = club.id
        JOIN CASHREGISTERS cr
        ON
            i.CASHREGISTER_CENTER = cr.CENTER
            AND i.CASHREGISTER_ID = cr.ID
        WHERE
            i.CENTER = :Center
            AND i.ENTRY_TIME >= :FromDate
            AND i.ENTRY_TIME < :ToDate + 60*60*1000*24
        UNION ALL
        SELECT
            c.center sales_center,
            club.SHORTNAME sales_club,
            cr.CENTER crCenter,
            cr.id crId,
            TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME pname,
            -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 4) excluding_Vat,
            -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 4) included_Vat,
            -ROUND(cl.TOTAL_AMOUNT, 4) total_Amount,
            cl.RATE vat_rate,
            c.EMPLOYEE_CENTER || 'emp' || c.EMPLOYEE_ID emp_id
        FROM
            CREDIT_NOTES c
        JOIN CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        JOIN CENTERS club
        ON
            c.center = club.id
        JOIN CASHREGISTERS cr
        ON
            c.CASHREGISTER_CENTER = cr.CENTER
            AND c.CASHREGISTER_ID = cr.ID
        WHERE
            c.CENTER = :Center
            AND c.ENTRY_TIME >= :FromDate
            AND c.ENTRY_TIME < :ToDate + 60*60*1000*24
    )
GROUP BY
    sales_center,
    sales_club,
	dato,
    crId,
    pname,
    vat_rate
ORDER BY
    1,
    2 DESC,
    3