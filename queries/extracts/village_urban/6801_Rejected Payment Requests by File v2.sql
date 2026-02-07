SELECT
    p.CENTER||'p'||p.id AS memberid,
    p.FULLNAME,
    prs.ref,
    DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manuel',5, 'Rejected, clearinghouse',6,
    'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',
    12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17,
    'Failed, payment revoked',18, 'Done, partial', 19, 'Failed, unsupported', 21, 'Fail, debt case exists', 'UNDEFINED') AS STATE,
    pr.REQ_AMOUNT,
    prs.OPEN_AMOUNT Open_amount_still_unpaid,
    ar.balance AS Account_Balance,
    pr.REQ_DATE,
    pr.DUE_DATE,
    pr.XFR_AMOUNT AS import_file_amount,
    pr.XFR_DATE   AS import_file_date,
    pr.XFR_INFO   AS rejection_info,
    pr.REJECTED_REASON_CODE,
    pr.FULL_REFERENCE,
    pr.REQ_DELIVERY AS payment_export_file,
	SUM(art.UNSETTLED_AMOUNT) AS UNSETTLED_AMOUNT
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    pr.CENTER = ar.CENTER
AND pr.ID = ar.ID
JOIN
    PERSONS p
ON
    ar.CUSTOMERCENTER = p.center
AND ar.CUSTOMERID = p.id
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
	ar_trans art 
	ON art.PAYREQ_SPEC_CENTER = prs.CENTER AND art.PAYREQ_SPEC_ID = prs.ID AND art.PAYREQ_SPEC_SUBID = prs.SUBID
WHERE
    pr.XFR_DELIVERY = $$clearing_in$$
GROUP  BY
	p.CENTER,
	p.ID,
	p.FULLNAME,
	prs.REF,
	pr.STATE,
	pr.REQ_AMOUNT,
	prs.OPEN_AMOUNT,
	ar.BALANCE,
	pr.REQ_DATE,
    pr.DUE_DATE,
    pr.XFR_AMOUNT,
    pr.XFR_DATE,
    pr.XFR_INFO,
    pr.REJECTED_REASON_CODE,
    pr.FULL_REFERENCE,
    pr.REQ_DELIVERY 