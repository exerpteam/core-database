-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    collections.BANK_DATE,
    CASE
        WHEN collections.type = 'REFUND'
        THEN 'DEBIT'
        ELSE'CREDIT'
    END                     AS CreditDebit,
    collections.SENT_AMOUNT AS TOTAL,
    memberId
FROM
    (
        SELECT
            p.center,
            p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID memberId,
            p.FULLNAME,
            CASE pr.REQUEST_TYPE 
                WHEN  1 THEN 'PAYMENT'
                WHEN  5 THEN 'REFUND'
                WHEN  6 THEN 'REPRESENTATION'
                WHEN  8 THEN 'ZERO'
                ELSE 'UNKNOWN' 
            END  AS "type",
            CASE pr.STATE
                WHEN     '1' THEN  'New'
                WHEN     '2' THEN  'Sent'
                WHEN     '3' THEN  'Done'
                WHEN     '4' THEN  'Done maual'
                WHEN     '5' THEN  'Rejected, clearinghouse'
                WHEN     '6' THEN  'Rejected, bank'
                WHEN     '7' THEN  'Rejected, debtor'
                WHEN     '8' THEN  'Cancelled'
                WHEN     '12' THEN 'Failed, no creditor'
                WHEN     '17' THEN  'Rejected, debtor'
                WHEN     '19' THEN  'Failed, not supported'
             END AS  state,
            prs.REQUESTED_AMOUNT                            INIT_AMOUNT,
            TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD')    ORIG_DUE_DATE,
            pr.REQ_AMOUNT                                   SENT_AMOUNT,
            pr.DUE_DATE                                     DEDUCTION_DATE,
            TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')              BANK_DATE,
            pag.ref                                      AS COLLECTION_BACS_REF,
            pag.INDIVIDUAL_DEDUCTION_DAY                    NORMAL_DD_DAY,
            pr.XFR_INFO                                     reasonCode,
            clo.id                                       AS SUBMISSION_FILE,
            clo.SENT_DATE
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pr.CENTER = pag.center
        AND pr.id = pag.id
        AND pr.AGR_SUBID = pag.subid
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
        JOIN
            CLEARING_OUT clo
        ON
            clo.ID = pr.REQ_DELIVERY
        WHERE
            pr.DUE_DATE >= :fromDate 
                    AND pr.DUE_DATE <= :toDate
        and pr.center IN ( :scope ) 
    ) collections
UNION ALL
SELECT
    bounces.BANK_DATE,
    'DEBIT'              AS CreditDebit,
    -bounces.SENT_AMOUNT AS TOTAL,
    memberId
FROM
    (
        SELECT
            p.center,
            p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID memberId,
            p.FULLNAME,
            CASE pr.REQUEST_TYPE 
                WHEN  1 THEN 'PAYMENT'
                WHEN  5 THEN 'REFUND'
                WHEN  6 THEN 'REPRESENTATION'
                WHEN  8 THEN 'ZERO'
                ELSE 'UNKNOWN' 
            END  AS "type",
            CASE pr.STATE
                WHEN     '1' THEN  'New'
                WHEN     '2' THEN  'Sent'
                WHEN     '3' THEN  'Done'
                WHEN     '4' THEN  'Done maual'
                WHEN     '5' THEN  'Rejected, clearinghouse'
                WHEN     '6' THEN  'Rejected, bank'
                WHEN     '7' THEN  'Rejected, debtor'
                WHEN     '8' THEN  'Cancelled'
                WHEN     '12' THEN 'Failed, no creditor'
                WHEN     '17' THEN  'Rejected, debtor'
                WHEN     '19' THEN  'Failed, not supported'
             END AS  state,       
            prs.REQUESTED_AMOUNT                            INIT_AMOUNT,
            TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD')    ORIG_DUE_DATE,
            pr.REQ_AMOUNT                                   SENT_AMOUNT,
            pr.DUE_DATE                                     DEDUCTION_DATE,
            pr.XFR_DATE                                     REJECTED_DATE,
            TO_CHAR(pr.XFR_DATE, 'YYYY-MM-DD')              BANK_DATE,
            pag.ref                                      AS CollectionBacsRef,
            pag.INDIVIDUAL_DEDUCTION_DAY                    NORMAL_DD_DAY,
            pr.XFR_INFO                                     reasonCode ,
            cli.id                                       AS REJECTION_FILE ,
            cli.GENERATED_DATE
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PAYMENT_AGREEMENTS pag
        ON
            pr.CENTER = pag.center
        AND pr.id = pag.id
        AND pr.AGR_SUBID = pag.subid
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
        JOIN
            CLEARING_IN cli
        ON
            cli.ID = pr.XFR_DELIVERY
        AND pr.REQ_DELIVERY IS NOT NULL
        WHERE
            pr.DUE_DATE >= :fromDate
        AND pr.DUE_DATE <=  :toDate
        and pr.center IN ( :scope ) 
    ) bounces