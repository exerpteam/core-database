SELECT DISTINCT
    p.center ||'p'|| p.id AS memberid,
    pr.req_date,
    prs.requested_amount,
    art.amount AS paid_amount,
    prs.open_amount,
    prs.ref,
    pr.creditor_id,
    longtodateC(art.entry_time, art.center) AS "Entry time",
    act.aggregated_transaction_center ||'agt'|| aggregated_transaction_id AS "AGT",
    act.info,
    act.info_type
FROM
    PAYMENT_REQUESTS pr
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
    AR_TRANS art
ON
    prs.CENTER = art.PAYREQ_SPEC_CENTER
AND prs.ID = art.PAYREQ_SPEC_ID
AND prs.SUBID = art.PAYREQ_SPEC_SUBID
AND art.ref_type = 'ACCOUNT_TRANS'
JOIN
account_trans act
ON
act.center = art.ref_center
AND act.id = art.ref_id
AND act.subid = art.ref_subid
AND act.info NOT LIKE 'Transfer'
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
AND ar.ID = art.ID
AND ar.AR_TYPE = 4
JOIN
    Persons p
ON
    ar.CUSTOMERCENTER = p.CENTER
AND ar.CUSTOMERID = p.ID
WHERE
    p.center = 584
AND req_date BETWEEN :datefrom AND :dateto
AND pr.clearinghouse_id NOT IN (2215,
                                2412)
AND prs.paid_state = 'CLOSED'
AND prs.requested_amount > 0