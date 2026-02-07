SELECT
    art.center||'ar'||art.id||'art'||art.subid AS "ID",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "PERSON_ID",
    CASE
        WHEN P.SEX = 'C'
        THEN
            CASE
                WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                        OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (
                        SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                            AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END AS "COMPANY_ID",
    CASE
        WHEN ar.ar_type = 1
        THEN 'CASH'
        WHEN ar.ar_type = 4
        THEN 'PAYMENT'
        WHEN ar.ar_type = 5
        THEN 'EXTERNAL_DEBT'
        WHEN ar.ar_type = 6
        THEN 'INSTALLMENT_PLAN'
    END                                           AS "ACCOUNT_TYPE",
    art.status                                    AS "STATUS",
    art.text                                      AS "TEXT",
    art.amount                                    AS "AMOUNT",
    art.due_date                                  AS "DUE_DATE",
        CASE
        WHEN art.collected = 0
        THEN 'UNCOLLECTED'
        WHEN art.collected = 1
        THEN 'COLLECTED'
        WHEN art.collected = 2
        THEN 'PAYMENT'
        WHEN art.collected = 3
        THEN 'REVOKMENT'
        WHEN art.collected = 4
        THEN 'CASH_TO_PAYMENT'
        WHEN art.collected = 5
        THEN 'INSTALLMENT_TO_PAYMENT'
        WHEN art.collected = 6
        THEN 'PAYMENT_TO_EXTERNAL_DEBT'
        WHEN art.collected IS NULL
        THEN NULL
        ELSE 'UNKNOWN'
    END AS "COLLECTION_STATE",
    CASE
        WHEN art.ref_type = 'ACCOUNT_TRANS'
        THEN 'ACCOUNT_TRANS'
        WHEN art.ref_type = 'INVOICE'
        THEN 'SALE_LOG'
        WHEN art.ref_type = 'CREDIT_NOTE'
        THEN 'SALE_LOG'
    END AS "REF_TYPE",
    CASE
        WHEN art.ref_type = 'ACCOUNT_TRANS'
        THEN art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid
        WHEN art.ref_type = 'INVOICE'
        THEN art.ref_center||'inv'||art.ref_id
        WHEN art.ref_type = 'CREDIT_NOTE'
        THEN art.ref_center||'cred'||art.ref_id
    END            AS "REF_ID",
    art.entry_time AS "ENTRY_DATETIME",
    art.trans_time AS "BOOK_DATETIME",
    CASE
        WHEN (ep.CENTER != ep.TRANSFERS_CURRENT_PRS_CENTER
                OR ep.id != ep.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = ep.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = ep.TRANSFERS_CURRENT_PRS_ID)
        ELSE ep.EXTERNAL_ID
    END                  AS "EMPLOYEE_PERSON_ID",
    art.unsettled_amount AS "UNSETTLED_AMOUNT",
    art.installment_plan_id AS "INSTALLMENT_PLAN_ID",
    CASE
        WHEN art.payreq_spec_center IS NOT NULL THEN 
            art.payreq_spec_center||'ar'||art.payreq_spec_id||'sp'||art.payreq_spec_subid 
        ELSE null
    END AS  "PAYMENT_REQUEST_SPEC_ID",
    art.center           AS "CENTER_ID",
    art.last_modified    AS "ETS"
FROM
    ar_trans art
JOIN
    account_receivables ar
ON
    ar.center = art.center
    AND ar.id = art.id
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND ar.customerid = p.id
LEFT JOIN
    employees emp
ON
    emp.center = art.employeecenter
    AND emp.id = art.employeeid
LEFT JOIN
    persons ep
ON
    ep.center = emp.personcenter
    AND ep.id = emp.personid
