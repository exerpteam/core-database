SELECT
    SUBSTR(prodExternalId, 1, 4) code,
    MIN(pname)                   text,
    SUBSTR(prodExternalId, 6, 2) depNo,
    
    '001'    fund,
    CASE
        WHEN REGEXP_COUNT(prodExternalId,'-') = 2
        THEN SUBSTR(prodExternalId, instr(prodExternalId,'-',-1)+1)
    END   AS "ID End",
    --    vat_rate,
    --    ROUND(SUM(excluding_Vat), 2) excl_vat,
    --    ROUND(SUM(included_Vat), 2) incl_vat,
    ROUND(SUM(total_amount), 2) tot_amount
FROM
    (
        SELECT
            i.center                                        sales_center,
            club.SHORTNAME                                  sales_club,
            cr.CENTER                                       crCenter,
            cr.id                                           crId,
            TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME                                       pname,
            CASE
                WHEN prod.EXTERNAL_ID IS NULL
                THEN 'CL  -' || prod.id
                ELSE prod.EXTERNAL_ID
            END                                                                prodExternalId,
            ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),4) excluding_Vat,
            ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),4)                     included_Vat,
            ROUND(il.TOTAL_AMOUNT, 4)                                          total_Amount,
            il.RATE                                                            vat_rate,
            i.EMPLOYEE_CENTER || 'emp' || i.EMPLOYEE_ID                        emp_id
        FROM
            INVOICES i
        JOIN
            INVOICELINES il
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        JOIN
            CENTERS club
        ON
            i.center = club.id
        JOIN
            CASHREGISTERS cr
        ON
            i.CASHREGISTER_CENTER = cr.CENTER
            AND i.CASHREGISTER_ID = cr.ID
        WHERE
            i.CENTER = :Centre
            AND cr.CENTER = :Centre
            AND i.ENTRY_TIME >
            (
                SELECT
                    MIN(crr.STARTTIME)
                FROM
                    PULSE.CASHREGISTERREPORTS crr
                WHERE
                    crr.CENTER = cr.CENTER
                    AND crr.ID = cr.ID
                    AND crr.REPORTTIME > :FromDate
                    AND crr.REPORTTIME < :ToDate + 60*60*1000*24 )
            AND i.ENTRY_TIME <
            (
                SELECT
                    MAX(crr.REPORTTIME)
                FROM
                    PULSE.CASHREGISTERREPORTS crr
                WHERE
                    crr.CENTER = cr.CENTER
                    AND crr.ID = cr.ID
                    AND crr.REPORTTIME > :FromDate
                    AND crr.REPORTTIME < :ToDate + 60*60*1000*24 )
        UNION ALL
        SELECT
            c.center                                        sales_center,
            club.SHORTNAME                                  sales_club,
            cr.CENTER                                       crCenter,
            cr.id                                           crId,
            TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME                                       pname,
            CASE
                WHEN prod.EXTERNAL_ID IS NULL
                THEN 'CL  -' || prod.id
                ELSE prod.EXTERNAL_ID
            END                                                                          prodExternalId,
            -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 4) excluding_Vat,
            -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 4)                             included_Vat,
            -ROUND(cl.TOTAL_AMOUNT, 4)                                                   total_Amount,
            cl.RATE                                                                      vat_rate,
            c.EMPLOYEE_CENTER || 'emp' || c.EMPLOYEE_ID                                  emp_id
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
            CENTERS club
        ON
            c.center = club.id
        JOIN
            CASHREGISTERS cr
        ON
            c.CASHREGISTER_CENTER = cr.CENTER
            AND c.CASHREGISTER_ID = cr.ID
        WHERE
            c.CENTER = :Centre
            AND cr.CENTER = :Centre
            AND c.ENTRY_TIME >
            (
                SELECT
                    MIN(crr.STARTTIME)
                FROM
                    PULSE.CASHREGISTERREPORTS crr
                WHERE
                    crr.CENTER = cr.CENTER
                    AND crr.ID = cr.ID
                    AND crr.REPORTTIME > :FromDate
                    AND crr.REPORTTIME < :ToDate + 60*60*1000*24 )
            AND c.ENTRY_TIME <
            (
                SELECT
                    MAX(crr.REPORTTIME)
                FROM
                    PULSE.CASHREGISTERREPORTS crr
                WHERE
                    crr.CENTER = cr.CENTER
                    AND crr.ID = cr.ID
                    AND crr.REPORTTIME > :FromDate
                    AND crr.REPORTTIME < :ToDate + 60*60*1000*24 ) )
GROUP BY
    sales_center,
    sales_club,
    prodExternalId,
    vat_rate
HAVING
    ROUND(SUM(excluding_Vat), 2) <> 0
ORDER BY
    1,
    2 DESC,
    3