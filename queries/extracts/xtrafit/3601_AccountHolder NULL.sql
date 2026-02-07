SELECT
    p.center || 'p' ||p.id AS Member_ID,
    prs.ref                AS invoice_id,
    pr.Req_Amount          AS Requested_Amount,
    pr.Req_date            AS Request_Date,
    ch.Name                AS Clearinghouse_Name,
    longtodateC(pa.creation_time, pa.CENTER) as creation_time
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
AND ar.ID = pr.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID
JOIN
    Clearinghouses ch
ON
    pr.clearinghouse_id=ch.id
JOIN
    Payment_agreements pa
ON
    ar.center = pa.center
AND ar.id = pa.id
JOIN
    payment_request_specifications prs
ON
    pr.inv_coll_center = prs.center
AND pr.inv_coll_id = prs.id
AND pr.inv_coll_subid = prs.subid
WHERE     pr.state=1 --state new
AND pa.bank_account_holder IS NULL
AND ch.ctype= 192  --sepa clearinghouse
AND p.center IN (:scope)
AND pa.active=true