SELECT
    p.center as "center ID",
    p.center||'p'||p.id as "member ID",
    p.FULLNAME,
    round (sum (art.UNSETTLED_AMOUNT), 2)                                                as "Overdue Amount",
    case when cc.CLOSED = 0 then 'Has Debt Collection Case' else 'No Open Debt Case' end as "Debt Case",
    ch.NAME                                                                            as "Clearinghouse Name"
    
FROM
    persons p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
AND art.ID = ar.ID
LEFT JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.CENTER
AND cc.PERSONID = p.ID
AND cc.CLOSED = 0
AND cc.MISSINGPAYMENT = 1
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
AND pa.id = pac.ACTIVE_AGR_ID
AND pa.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    CLEARINGHOUSES ch
ON
    pa.CLEARINGHOUSE = ch.id
WHERE
    p.SEX != 'C'
AND art.DUE_DATE < current_date
AND art.UNSETTLED_AMOUNT < 0
AND cc.CLOSED is null

GROUP BY
    p.center,
    p.center|| 'p' ||p.id,
    p.FULLNAME,
    cc.CLOSED,
    ch.name