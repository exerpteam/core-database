-- This is the version from 2026-02-05
--  
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
    TO_CHAR(pr.REQ_DATE, 'YYYY-MM-DD')              DEDUCTION_DATE,
    pr.REQ_AMOUNT                                   SENT_AMOUNT,
    TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')              BANK_DATE,
    pr.XFR_INFO                                     ARUDD_REASON_CODE,
    pag.BANK_ACCOUNT_HOLDER                      AS ACCOUNT_HOLDER_NAME,
    pag.ref                                      AS BACS_REF,
    ch.name                                      AS clearinghouseName,
    (CASE ch.ctype
			WHEN 2 THEN 'dk_pbs'
            WHEN 8 THEN 'dk_invoice'
            WHEN 141 THEN 'pay_ex_creditcard'
            WHEN 184 THEN 'adyen_token_creditcard'
            ELSE 'Unknown'
	END) AS clearinghousetype
FROM fw.payment_requests pr
JOIN fw.payment_agreements pag
        ON pr.center = pag.center
        AND pr.id = pag.id
        AND pr.agr_subid = pag.subid
JOIN fw.clearinghouses ch
        ON ch.id = pr.clearinghouse_id
JOIN fw.account_receivables ar
        ON ar.center = pr.center
        AND ar.id = pr.id
JOIN fw.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
JOIN fw.payment_request_specifications prs
        ON prs.center = pr.inv_coll_center
        AND prs.id = pr.inv_coll_id
        AND prs.subid = pr.inv_coll_subid
WHERE
        pr.DUE_DATE >= $$FromDate$$
        AND pr.DUE_DATE <= $$ToDate$$
        AND 
        ( 
                (10 = $$ClearinghouseName$$)
                OR 
                (ch.id = $$ClearinghouseName$$) 
        )