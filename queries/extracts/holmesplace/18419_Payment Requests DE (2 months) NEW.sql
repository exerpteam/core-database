-- The extract is extracted from Exerp on 2026-02-08
--  

WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(ADD_MONTHS(TO_DATE(getcentertime(c.id),'YYYY-MM-DD HH24:MI'),-2),
            'YYYY-MM-DD HH24:MI'), co.DEFAULTTIMEZONE) AS FROMDATE,
            c.id                                       AS CLUBID
        FROM
            HP.CENTERS c
        JOIN
            HP.COUNTRIES co
        ON
            c.COUNTRY = co.ID
        WHERE
            co.ID = 'DE'
    )
SELECT
    p.CENTER || 'p' || p.ID AS PersonId,
    ar.BALANCE,
    pcc.NAME,
    p.SEX,
CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS PERSON_STATUS,
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
AND pag.PAYMENT_CYCLE_CONFIG_ID IN (2605,2604,2606,2404)
AND pag.STATE IN (2,4,13)
AND ar.BALANCE < 0
AND art.COLLECTED = 0
AND art.ENTRY_TIME > par.FROMDATE
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
        AND pr.REQ_DATE >= to_date('2024-04-01','YYYY-MM-DD') )
GROUP BY
    p.CENTER,
	p.STATUS,
    p.ID,
    pcc.NAME,
    p.SEX,
    ar.BALANCE