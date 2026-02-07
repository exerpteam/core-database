select
            p.center, p.id,
            p.FULLNAME as MEMBER_NAME,
            DECODE(pr.REQUEST_TYPE, 1, 'PAYMENT', 5, 'REFUND', 6, 'REPRESENTATION', 8, 'ZERO', 'UNKNOWN') type,
            DECODE(pr.STATE, '1', 'New', '2', 'Sent', '3', 'Done', '4', 'Done maual', '5', 'Rejected, clearinghouse',
            '6', 'Rejected, bank', '7', 'Rejected, debtor', '8', 'Cancelled', '12','Failed, no creditor', '17',
            'Rejected, debtor', '19', 'Failed, not supported') state,
            pag.INDIVIDUAL_DEDUCTION_DAY NORMAL_DD_DAY,
            TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') INIT_COLL_DATE,
            prs.REQUESTED_AMOUNT INIT_AMOUNT,
            TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD') DEDUCTION_DATE,
            pr.REQ_AMOUNT SENT_AMOUNT,
            to_char(pr.DUE_DATE, 'YYYY-MM-DD') BANK_DATE,
            pr.XFR_INFO ARUDD_REASON_CODE,
            pag.BANK_ACCOUNT_HOLDER as ACCOUNT_HOLDER_NAME,
            pag.ref as BACS_REF,
            clo.id as SUBMISSION_FILE,
            clo.SENT_DATE as FILE_SENT_DATE
            --,art.amount
            

FROM PUREGYM.PAYMENT_REQUESTS pr
JOIN PUREGYM.PAYMENT_AGREEMENTS pag
        on pr.CENTER = pag.center and pr.id = pag.id and pr.AGR_SUBID = pag.subid
JOIN PUREGYM.ACCOUNT_RECEIVABLES ar on ar.center = pag.center and ar.id = pag.id
JOIN PUREGYM.PERSONS p
        ON p.center = ar.CUSTOMERCENTER AND p.id = ar.CUSTOMERID
JOIN PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prs on
            prs.center = pr.INV_COLL_CENTER
            AND prs.id = pr.INV_COLL_ID
            AND prs.subid = pr.INV_COLL_SUBID
JOIN PUREGYM.CLEARING_OUT clo on clo.ID = pr.REQ_DELIVERY
--JOIN AR_TRANS art on art.CENTER = ar.center and art.id = ar.id and art.COLLECTED = 2 and art.PAYREQ_SPEC_CENTER = prs.center and art.PAYREQ_SPEC_ID = prs.id and art.PAYREQ_SPEC_SUBID = prs.subid
--and art.TRANS_TIME = datetolongTZ(to_char(pr.DUE_DATE, 'YYYY-MM-DD HH24:MI'), 'Europe/London')
where pr.DUE_DATE >= :FromDate and pr.DUE_DATE <= :ToDate
and pr.CLEARINGHOUSE_ID = 1 AND pr.center IN (:scope )
            


