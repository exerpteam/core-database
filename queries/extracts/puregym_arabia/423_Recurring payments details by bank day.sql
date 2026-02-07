SELECT
    p.center,
    p.id,
    p.FULLNAME AS MEMBER_NAME,
	p.external_id,
    CASE pr.REQUEST_TYPE
        WHEN 1
        THEN 'PAYMENT'
        WHEN 5
        THEN 'REFUND'
        WHEN 6
        THEN 'REPRESENTATION'
        WHEN 8
        THEN 'ZERO'
        ELSE 'UNKNOWN'
    END AS type,
    CASE pr.STATE
        WHEN 1
        THEN 'New'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Done'
        WHEN 4
        THEN 'Done manual'
        WHEN 5
        THEN 'Rejected, clearinghouse'
        WHEN 6
        THEN 'Rejected, bank'
        WHEN 7
        THEN 'Rejected, debtor'
        WHEN 8
        THEN 'Cancelled'
        WHEN 12
        THEN 'Failed, no creditor'
        WHEN 17
        THEN 'Rejected, debtor'
        WHEN 19
        THEN 'Failed, not supported'
        ELSE 'UNDEFINED'
    END                                          AS state,
    pag.INDIVIDUAL_DEDUCTION_DAY                    NORMAL_DD_DAY,
    TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD')    INIT_COLL_DATE,
    prs.REQUESTED_AMOUNT                            INIT_AMOUNT,
    TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')              DEDUCTION_DATE,
    pr.REQ_AMOUNT                                   SENT_AMOUNT,
    TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')              BANK_DATE,
    pr.XFR_INFO                                     ARUDD_REASON_CODE,
    pag.BANK_ACCOUNT_HOLDER                      AS ACCOUNT_HOLDER_NAME,
    pag.ref                                      AS BACS_REF,
    ch.name                                      AS clearinghouseName
FROM
    PAYMENT_REQUESTS pr
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pr.CENTER = pag.center
    AND pr.id = pag.id
    AND pr.AGR_SUBID = pag.subid
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pag.CLEARINGHOUSE
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pag.center
    AND ar.id = pag.id
JOIN
    PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.center = pr.INV_COLL_CENTER
    AND prs.id = pr.INV_COLL_ID
    AND prs.subid = pr.INV_COLL_SUBID
WHERE
    pr.DUE_DATE >= $$FromDate$$
    AND pr.DUE_DATE <= $$ToDate$$
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )