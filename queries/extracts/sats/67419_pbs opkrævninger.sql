SELECT
    ar.CUSTOMERCENTER,
    ar.CUSTOMERID,
    p.ssn,
    prs.REF,
    pr.REQ_AMOUNT,
    pr.REQ_DATE,
    pr.REQ_DELIVERY,
    ar.BALANCE
FROM
    PAYMENT_REQUESTS pr
JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
    pr.center = ar.center
    AND pr.id = ar.id
join Persons p
on ar.CUSTOMERCENTER = p.center
and ar.CUSTOMERID = p.id
WHERE
    pr.CLEARINGHOUSE_ID = 3212
    AND pr.REQ_DATE = :request_date
ORDER by ar.CENTER, ar.id