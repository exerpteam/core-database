SELECT
    ar.CUSTOMERCENTER || 'p' ||        ar.CUSTOMERID pid,
    longToDate(art.TRANS_TIME) TRANS_TIME,
    art.DUE_DATE,
    art.TEXT
FROM
    PRODUCTS prod
JOIN
    INVOICELINES invl
ON
    invl.PRODUCTCENTER = prod.CENTER
    AND invl.PRODUCTID = prod.ID
    AND prod.GLOBALID = 'ARC_ADMIN_FEE'
JOIN
    AR_TRANS art
ON
    art.REF_TYPE = 'INVOICE'
    AND art.REF_CENTER = invl.CENTER
    AND art.REF_ID = invl.ID
    AND art.UNSETTLED_AMOUNT < 0
    AND art.DUE_DATE < SYSDATE
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.id = art.ID
    AND ar.AR_TYPE = 4
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs
        WHERE
            prs.CENTER = ar.CENTER
            AND prs.ID = ar.ID
            AND prs.OPEN_AMOUNT !=0 )
and ar.center in ($$scope$$)