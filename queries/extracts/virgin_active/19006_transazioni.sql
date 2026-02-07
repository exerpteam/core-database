SELECT
    c.id                                    AS "Club Id",
    c.name                                  AS "Club Name",
    p.center || 'p' || p.id                 AS PERSONID,
    longToDateC(art.entry_time, art.center)    entry_time,
    art.due_date,
    DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed',17,'Revoked by debitor',18,'Done partial',19,'Fail unsupported','UNDEFINED') AS request_state,
    invl.total_amount                                                                                                                                                                        AS "Gross Amount",
    act.amount                                                                                                                                                                               AS "Net Amount",
    vatact.amount                                                                                                                                                                            AS "VAT Amount",
    NVL(ROUND((vatact.amount/NULLIF(invl.total_amount,0))*100, 2),0)                                                                                                                                                                                                        AS "VAT %"
FROM
    PAYMENT_REQUESTS pr
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pr.INV_COLL_CENTER
    AND prs.ID = pr.INV_COLL_ID
    AND prs.SUBID = pr.INV_COLL_SUBID
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
    AND art.REF_TYPE = 'INVOICE'
JOIN
    INVOICELINES invl
ON
    invl.CENTER = art.REF_CENTER
    AND invl.ID = art.REF_ID
    AND invl.subid = art.subid
JOIN
    account_trans act
ON
    act.center = invl.account_trans_center
    AND act.id = invl.account_trans_id
    AND act.subid = invl.account_trans_subid
JOIN
    account_trans vatact
ON
    vatact.center = invl.vat_acc_trans_center
    AND vatact.id = invl.vat_acc_trans_id
    AND vatact.subid = invl.vat_acc_trans_subid
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = prs.CENTER
    AND ar.ID = prs.ID
JOIN
    CENTERS c
ON
    c.ID = ar.CUSTOMERCENTER
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
WHERE
    P.center IN ($$scope$$)
    AND pr.STATE NOT IN (1)
    AND pr.REQ_DATE BETWEEN $$reqFromDate$$ AND $$reqToDate$$