SELECT
    ar.CUSTOMERCENTER ,
    ar.CUSTOMERID,
    c.SHORTNAME   AS Center,
    ch.NAME       AS "Clearing House",
    pr.REQ_AMOUNT AS "Request amount",
    pr.REQ_DATE   AS "Request date"
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
    AND ar.AR_TYPE = 4
JOIN
    centers c
ON
    c.id = ar.center
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.CENTER
    AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
    ON
    pa.center = pac.ACTIVE_AGR_CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pr.CLEARINGHOUSE_ID
WHERE
    pr.REQUEST_TYPE = 5
    AND pr.STATE = 1
    AND c.id IN ($$scope$$)
    AND pa.BANK_ACCNO IS NULL