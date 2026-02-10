-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8890

SELECT
    p2.EXTERNAL_ID,
    SUM(pr.REQ_AMOUNT)     PAYED,
    COALESCE(ccc.amount,0) AS "Overdue Debt"
FROM
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID
    AND pr.STATE IN (3,4)
JOIN
    PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
JOIN
    CENTERS c
ON
    c.id = p2.CENTER
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p2.CENTER
    AND ccc.PERSONID = p2.ID
    AND ccc.CLOSED = 0
    AND ccc.MISSINGPAYMENT =1
WHERE
    p2.STATUS NOT IN (4,5,7,8)
    AND p2.PERSONTYPE != 2
    AND c.COUNTRY IN ('AT',
                      'CH')
GROUP BY
    p2.EXTERNAL_ID,
    ccc.AMOUNT,
    p2.center||'p'||p2.id