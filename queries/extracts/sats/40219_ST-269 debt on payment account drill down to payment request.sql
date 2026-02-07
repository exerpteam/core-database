SELECT DISTINCT
    p.lastname                                name,
    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
    SUM(art.UNSETTLED_AMOUNT)                 open_debt,
    prs.REF                                   payment_request_ref,
    pr.REQ_DATE                               payment_request_date
FROM
    ACCOUNT_RECEIVABLES ar
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
	AND p.SEX = 'C'
join CENTERS c on c.id = p.center and c.COUNTRY = 'NO'
JOIN
    AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
    AND ar.AR_TYPE IN ($$account_type$$)
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
    AND prs.ID = art.PAYREQ_SPEC_ID
    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
WHERE
	art.due_date is not null 
    and art.DUE_DATE < exerpsysdate()
    AND art.STATUS IN ('NEW','OPEN')
    AND art.UNSETTLED_AMOUNT < 0
	and ar.BALANCE < 0
GROUP BY
    p.lastname ,
    ar.CUSTOMERCENTER ,
    ar.CUSTOMERID ,
    prs.REF ,
    pr.REQ_DATE