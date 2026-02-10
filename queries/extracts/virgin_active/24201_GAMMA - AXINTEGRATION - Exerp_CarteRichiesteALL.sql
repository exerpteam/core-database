-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.EXTERNAL_ID                                                             AS clubId,
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))) AS personId,
    pr.REQ_AMOUNT                                                             AS importoRichiesto
FROM
    PERSONS p1
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p1.CENTER
    AND ar.CUSTOMERID = p1.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.id
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_SUBID = prs.SUBID
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_CENTER = prs.CENTER
LEFT JOIN
    INVOICELINES invl
ON
    invl.ID = art.REF_ID
    AND invl.CENTER = art.REF_CENTER
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = invl.ACCOUNT_TRANS_CENTER
    AND act.ID = invl.ACCOUNT_TRANS_ID
    AND act.SUBID = invl.ACCOUNT_TRANS_SUBID
INNER JOIN
    ACCOUNTS debac
ON
    debac.center = act.DEBIT_ACCOUNTCENTER
    AND debac.ID = act.DEBIT_ACCOUNTID
INNER JOIN
    ACCOUNTS credac
ON
    credac.center = act.CREDIT_ACCOUNTCENTER
    AND credac.ID = act.CREDIT_ACCOUNTID
LEFT JOIN
    CENTERS c
ON
    c.ID = pr.CENTER
WHERE
    --PR.center = 102
    c.COUNTRY = 'IT'
    AND extract(MONTH FROM pr.req_date) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE,-1))
    AND extract(YEAR FROM pr.req_date) = extract(YEAR FROM ADD_MONTHS(SYSDATE,-1))
    AND extract(DAY FROM pr.req_date) <= 2
    AND pr.STATE IS NOT NULL
    AND ART.REF_TYPE = 'INVOICE'
    --AND ar.CUSTOMERID = 7338
    AND art.COLLECTED_AMOUNT <> 0
    AND pr.CLEARINGHOUSE_ID IN(803,
                               2801,
                               2802,
                               2803,
                               2804)
GROUP BY
    c.EXTERNAL_ID,
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))),
    pr.REQ_AMOUNT,
    pr.CENTER,
    pr.ID,
    pr.SUBID,
    prs.OPEN_AMOUNT
ORDER BY
    c.EXTERNAL_ID,
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8)))