
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(TO_DATE('2020-10-31','YYYY-MM-DD'),'YYYY-MM-DD') || ' 00:00',
            co.DEFAULTTIMEZONE) AS FROMDATE,
            datetolongTZ(TO_CHAR(TO_DATE('2020-11-26','YYYY-MM-DD'),'YYYY-MM-DD') || ' 00:00',
            co.DEFAULTTIMEZONE) AS TODATE,
            c.id                AS CLUBID
        FROM
            HP.CENTERS c
        JOIN
            HP.COUNTRIES co
        ON
            c.COUNTRY = co.ID
        WHERE
            co.ID = 'AT'
    )
SELECT
    p.CENTER || 'p' || p.ID AS PersonId,
    pcc.NAME,
    p.SEX,
    COUNT(*) TOTAL_RENEWAL_TRANSACTIONS
FROM
    PERSONS p
JOIN
    PARAMS par
ON
    par.CLUBID = p.CENTER
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
AND ar.CUSTOMERID = p.ID
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.CENTER
AND pac.ACTIVE_AGR_ID = pag.ID
AND pac.ACTIVE_AGR_SUBID = pag.SUBID
JOIN
    HP.PAYMENT_CYCLE_CONFIG pcc
ON
    pcc.ID = pag.PAYMENT_CYCLE_CONFIG_ID
JOIN
    HP.AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
WHERE
    ar.AR_TYPE = 4
AND pag.PAYMENT_CYCLE_CONFIG_ID IN (2805,2806,2807,2804)
AND pag.STATE IN (2,4,13)
AND art.ENTRY_TIME > par.FROMDATE
AND art.ENTRY_TIME < par.TODATE
AND art.TEXT LIKE '%(Auto Renewal)'
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            HP.PAYMENT_REQUEST_SPECIFICATIONS prs
        JOIN
            HP.PAYMENT_REQUESTS pr
        ON
            prs.CENTER = pr.INV_COLL_CENTER
        AND prs.ID = pr.INV_COLL_ID
        AND prs.SUBID = pr.INV_COLL_SUBID
        WHERE
            ar.CENTER = prs.CENTER
        AND ar.ID = prs.ID
        AND pr.REQ_DATE >= to_date('2020-11-24','YYYY-MM-DD') )
GROUP BY
    p.CENTER,
    p.ID,
    pcc.NAME,
    p.SEX