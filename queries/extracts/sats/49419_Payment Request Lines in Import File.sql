SELECT DISTINCT
    p.CENTER||'p'||p.id AS "Person key",
    p.fullname ,
    act.CENTER||'acc'||act.id||'tr'||act.SUBID                                     AS Account_trans,
    DECODE(AR_TYPE,1,'Cash',4,'Payment Account',5,'Debt Account',6,'installment account') AS
    Account_placed_on,
    prs.ref,
    act.AMOUNT,
    exerpro.longtodate(act.TRANS_TIME) AS trans_time,
    exerpro.longtodate(act.ENTRY_TIME) AS entry_time
FROM
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    AR_TRANS art
ON
    art.center = ar.center
AND art.id = ar.id
JOIN
    SATS.PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    art.PAYREQ_SPEC_CENTER = prs.center
AND art.PAYREQ_SPEC_ID = prs.id
AND prs.SUBID = art.PAYREQ_SPEC_SUBID
JOIN
    SATS.PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    SATS.ACCOUNT_TRANS act
ON
    art.REF_CENTER = act.center
AND art.REF_ID = act.ID
AND art.REF_SUBID = act.SUBID
AND art.REF_TYPE = 'ACCOUNT_TRANS'
    --JOIN
    --    SATS.INVOICELINES inv
    --ON
    --    art.REF_ID = inv.ID
    --AND art.REF_CENTER = inv.center and inv.SUBID = art.SUBID
WHERE
    1=1
AND pr.XFR_DELIVERY = :fileid
ORDER BY
    p.CENTER||'p'||p.id,
    Account_placed_on DESC