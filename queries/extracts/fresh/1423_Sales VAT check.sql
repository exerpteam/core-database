SELECT
    center,
    COUNT(center) count_,
    name,
    debit,
    credit,
    SUM(amount) amount,
    debitvat,
    creditvat,
    SUM(amountvat) amountvat,
    ROUND(100 * (SUM(amountvat) / SUM(amount)),4) vatpct
FROM
    (
        SELECT
            i.center,
            TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME,
            ROUND(art.AMOUNT, 4) amount,
            debitacc.EXTERNAL_ID debit,
            creditacc.EXTERNAL_ID credit,
            debitvatacc.EXTERNAL_ID debitvat,
            creditvatacc.EXTERNAL_ID creditvat,
            ROUND(art_vat.AMOUNT, 4) amountvat
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
        JOIN ACCOUNT_TRANS art
        ON
            il.ACCOUNT_TRANS_CENTER = art.CENTER
            AND il.ACCOUNT_TRANS_ID = art.ID
            AND il.ACCOUNT_TRANS_SUBID = art.SUBID
        JOIN ACCOUNTS debitacc
        ON
            debitacc.center = art.DEBIT_ACCOUNTCENTER
            AND debitacc.id = art.DEBIT_ACCOUNTID
        JOIN ACCOUNTS creditacc
        ON
            creditacc.center = art.CREDIT_ACCOUNTCENTER
            AND creditacc.id = art.CREDIT_ACCOUNTID

        LEFT JOIN ACCOUNT_TRANS art_vat
        ON
            il.VAT_ACC_TRANS_CENTER = art_vat.CENTER
            AND il.VAT_ACC_TRANS_ID = art_vat.ID
            AND il.VAT_ACC_TRANS_SUBID = art_vat.SUBID
        LEFT JOIN ACCOUNTS debitvatacc
        ON
            debitvatacc.center = art_vat.DEBIT_ACCOUNTCENTER
            AND debitvatacc.id = art_vat.DEBIT_ACCOUNTID
        LEFT JOIN ACCOUNTS creditvatacc
        ON
            creditvatacc.center = art_vat.CREDIT_ACCOUNTCENTER
            AND creditvatacc.id = art_vat.CREDIT_ACCOUNTID

        WHERE
            i.center < 200
            AND il.TOTAL_AMOUNT <> 0
            AND i.TRANS_TIME >= :Date_from
            AND i.TRANS_TIME < :Date_to + 1000*3600*24
        UNION ALL
        SELECT
            c.center,
            TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD') dato,
            prod.NAME,
            -ROUND(art.AMOUNT, 4) amount,
            debitacc.EXTERNAL_ID debit,
            creditacc.EXTERNAL_ID credit,
            debitvatacc.EXTERNAL_ID debitvat,
            creditvatacc.EXTERNAL_ID creditvat,
            -ROUND(art_vat.AMOUNT, 4) amountvat
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
        JOIN ACCOUNT_TRANS art
        ON
            cl.ACCOUNT_TRANS_CENTER = art.CENTER
            AND cl.ACCOUNT_TRANS_ID = art.ID
            AND cl.ACCOUNT_TRANS_SUBID = art.SUBID
        JOIN ACCOUNTS debitacc
        ON
            debitacc.center = art.DEBIT_ACCOUNTCENTER
            AND debitacc.id = art.DEBIT_ACCOUNTID
        JOIN ACCOUNTS creditacc
        ON
            creditacc.center = art.CREDIT_ACCOUNTCENTER
            AND creditacc.id = art.CREDIT_ACCOUNTID
        LEFT JOIN ACCOUNT_TRANS art_vat
        ON
            cl.VAT_ACC_TRANS_CENTER = art_vat.CENTER
            AND cl.VAT_ACC_TRANS_ID = art_vat.ID
            AND cl.VAT_ACC_TRANS_SUBID = art_vat.SUBID
        LEFT JOIN ACCOUNTS debitvatacc
        ON
            debitvatacc.center = art_vat.DEBIT_ACCOUNTCENTER
            AND debitvatacc.id = art_vat.DEBIT_ACCOUNTID
        LEFT JOIN ACCOUNTS creditvatacc
        ON
            creditvatacc.center = art_vat.CREDIT_ACCOUNTCENTER
            AND creditvatacc.id = art_vat.CREDIT_ACCOUNTID
        WHERE
            c.center < 200
            AND cl.TOTAL_AMOUNT <> 0
            AND c.TRANS_TIME >= :Date_from
            AND c.TRANS_TIME < :Date_to + 1000*3600*24
    )
HAVING 
	SUM(amountvat) is null
GROUP BY
    center,
    name,
    debit,
    credit,
    debitvat,
    creditvat

ORDER BY
    center,
    name