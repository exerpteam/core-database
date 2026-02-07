SELECT
    p.center|| 'p' ||p.id memberid,
    p.FULLNAME,
    SUM(art.UNSETTLED_AMOUNT) AS "overdue amount",
    CASE
        WHEN cc.CLOSED = 0
        THEN 'Has Debt Collection Case'
        ELSE 'No Open Debt Case'
    END          AS "Debt Case",
    cc.STARTDATE AS "Debt Case Start Date",
    cc.AMOUNT "Debt Case Amount",
    ch.NAME
FROM
    persons p
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    SATS.AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
LEFT JOIN
    SATS.CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.CENTER
AND cc.PERSONID = p.ID
AND cc.CLOSED = 0
AND cc.MISSINGPAYMENT = 1
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.id = ar.id
LEFT JOIN
    SATS.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
AND pa.id = pac.ACTIVE_AGR_ID
AND pa.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    SATS.CLEARINGHOUSES ch
ON
    pa.CLEARINGHOUSE = ch.id
WHERE
    p.SEX = 'C'
AND p.center IN (100,200,250) --and p.ID = 2653
AND art.DUE_DATE < exerpsysdate()
AND art.UNSETTLED_AMOUNT < 0
GROUP BY
    p.center|| 'p' ||p.id ,
    p.FULLNAME,
    cc.CLOSED,
    cc.STARTDATE,
    cc.AMOUNT ,
    ch.NAME