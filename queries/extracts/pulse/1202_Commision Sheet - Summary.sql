select emp_id, PNAME, count(*), SUM(tot_amount)
from(
SELECT
    sales_club,
    dato,
    pname,
    person_name,
    person_Type,
    emp_id,
    vat_rate,
    SUM(excluding_Vat) excl_vat,
    SUM(included_Vat) incl_vat,
    SUM(total_amount) tot_amount
FROM
    (
        SELECT
            i.center sales_center,
            club.SHORTNAME sales_club,
            (
                SELECT DISTINCT
                    crt.center
                FROM
                    CASHREGISTERTRANSACTIONS crt
                WHERE
                    crt.CENTER = i.CASHREGISTER_CENTER
                    AND crt.ID = i.CASHREGISTER_ID
                    AND crt.PAYSESSIONID = i.PAYSESSIONID
            )
            cashRegisterCenter,
            TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') dato,
            prod.NAME pname,
            ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) excluding_Vat,
            ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),2) included_Vat,
            ROUND(il.TOTAL_AMOUNT, 2) total_Amount,
            il.RATE vat_rate,
            CASE
                WHEN i.PERSON_CENTER IS NOT NULL
                THEN i.PERSON_CENTER || 'p' || i.PERSON_ID
                ELSE NULL
            END person_id,
            CASE
                WHEN i.PERSON_CENTER IS NOT NULL
                THEN per.FIRSTNAME || ' ' || per.LASTNAME
                ELSE NULL
            END person_name,
            CASE
                WHEN i.PERSON_CENTER IS NOT NULL
                THEN DECODE ( per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,
                    'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')
                ELSE NULL
            END person_type,
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
        LEFT JOIN PERSONS per
        ON
            i.PERSON_CENTER = per.center
            AND i.PERSON_ID = per.id
        WHERE
            i.CENTER in (:Center)
            AND i.TRANS_TIME >= :FromDate
            AND i.TRANS_TIME < :ToDate + 60*60*1000*24
			AND il.TOTAL_AMOUNT <> 0
			AND (prod.PTYPE in (5,10,12,13) OR prod.GLOBALID = '30_DAY_NOTICE')
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    AR_TRANS art
                JOIN ACCOUNT_RECEIVABLES ar
                ON
                    ar.center = art.center
                    AND ar.id = art.id
                WHERE
                    art.REF_CENTER = i.CENTER
                    AND art.REF_ID = i.ID
                    AND art.REF_TYPE = 'INVOICE'
                    AND ar.AR_TYPE = 4
            )
        UNION ALL
        SELECT
            c.center sales_center,
            club.SHORTNAME sales_club,
            (
                SELECT DISTINCT
                    crt.center
                FROM
                    CASHREGISTERTRANSACTIONS crt
                WHERE
                    crt.CENTER = c.CASHREGISTER_CENTER
                    AND crt.ID = c.CASHREGISTER_ID
                    AND crt.PAYSESSIONID = c.PAYSESSIONID
            )
            cashRegisterCenter,
            TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD HH24:MI') dato,
            prod.NAME pname,
            -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 2) excluding_Vat,
            -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2) included_Vat,
            -ROUND(cl.TOTAL_AMOUNT, 2) total_Amount,
            cl.RATE vat_rate,
            CASE
                WHEN c.PERSON_CENTER IS NOT NULL
                THEN c.PERSON_CENTER || 'p' || c.PERSON_ID
                ELSE NULL
            END person_id,
            CASE
                WHEN c.PERSON_CENTER IS NOT NULL
                THEN per.FIRSTNAME || ' ' || per.LASTNAME
                ELSE NULL
            END person_name,
            CASE
                WHEN c.PERSON_CENTER IS NOT NULL
                THEN DECODE ( per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,
                    'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')
                ELSE NULL
            END person_type,
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
        LEFT JOIN PERSONS per
        ON
            c.PERSON_CENTER = per.center
            AND c.PERSON_ID = per.id
        WHERE
            c.CENTER in (:Center)
            AND c.TRANS_TIME >= :FromDate
            AND c.TRANS_TIME < :ToDate + 60*60*1000*24
			AND cl.TOTAL_AMOUNT <> 0
			AND (prod.PTYPE in (5,10,12,13) OR prod.GLOBALID = '30_DAY_NOTICE')
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    AR_TRANS art
                JOIN ACCOUNT_RECEIVABLES ar
                ON
                    ar.center = art.center
                    AND ar.id = art.id
                WHERE
                    art.REF_CENTER = c.CENTER
                    AND art.REF_ID = c.ID
                    AND art.REF_TYPE = 'CREDIT_NOTE'
                    AND ar.AR_TYPE = 4
            )
    )
GROUP BY 
    sales_center,
    sales_club,
    cashRegisterCenter,
    dato,
    pname,
    vat_rate,
    person_name,
    person_Type,
    emp_id
ORDER BY
    1,
    2 DESC,
    3)
group by emp_id, pname