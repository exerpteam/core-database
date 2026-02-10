-- The extract is extracted from Exerp on 2026-02-08
-- added PAID Column (settled amount).  Excludes payment requests if resent for the same due date period. Keeps the most recent one requested. But we seem to loose some poeple completely. Need to fix
WITH
    PAY_REQUESTS AS
    (
        SELECT
            payreq.*
        FROM
            PAYMENT_REQUESTS payreq
        JOIN
            payment_request_specifications payreqspec
        ON
            payreqspec.CENTER = payreq.INV_COLL_CENTER
        AND payreqspec.ID = payreq.INV_COLL_ID
        AND payreqspec.SUBID = payreq.INV_COLL_SUBID
        WHERE
            payreq.req_date =
            (
                SELECT
                    MAX(pr_new.req_date)
                FROM
                    PAYMENT_REQUESTS pr_new
                JOIN
                    payment_request_specifications prs_new
                ON
                    prs_new.CENTER = pr_new.INV_COLL_CENTER
                AND prs_new.ID = pr_new.INV_COLL_ID
                AND prs_new.SUBID = pr_new.INV_COLL_SUBID
                WHERE
                    pr_new.CENTER = payreq.CENTER
                AND pr_new.ID = payreq.ID
                AND prs_new.ref = payreqspec.ref
                AND pr_new.state != 8 )
    )
SELECT
    'INVOICE'                    AS "Doc Type",
    P.CENTER || 'inv' || invl.id AS "Inv Nr",
    invl.subid                   AS "Inv Line",
    'G/L Account'                AS "AccountType",
    '1000001'                    AS "GL Account",
    trans.TEXT                   AS "Description",
    invl.quantity                AS "Quantity",---missing if not ar transaction instead of invoice.
    invl.TOTAL_AMOUNT            AS "UnitPriceGross",
    CASE comp.fullname
        WHEN 'Nation Unis (UN)'
        THEN invl.TOTAL_AMOUNT
        ELSE invl.net_amount
    END AS "Total Net",---ok inc VAT if company is 'Nation Unis (UN)'
    CASE comp.fullname
        WHEN 'Nation Unis (UN)'
        THEN '0'
        ELSE invl.rate*100
    END AS "VATrate",--ok 0% if Diplomat
    CASE comp.fullname
        WHEN 'Nation Unis (UN)'
        THEN 'VAT-SALES 0%'
        ELSE vt.name
    END AS "VATrateName",---ok SALES 0% if Diplomat,
    ---ADDITIONAL INFORMATION
    comp.fullname           AS "Company",
    p.CENTER || 'p' || p.ID AS "Mem Nr",
    prs.REF                 AS "PR Ref",
    CASE pr.request_type
        WHEN 1
        THEN 'payment'
        WHEN 6
        THEN 'representation'
        ELSE 'undefinded'
    END                                AS "Request Type",
    TO_CHAR(pr.req_date, 'YYYY-MM-DD') AS "req date",
    TO_CHAR(pr.due_date, 'YYYY-MM-DD') AS "DueDate",
    p.blacklisted,
    ch.name AS "ClearingHouse",
    CASE
        WHEN ch.ctype IN (144,184)
        THEN 'CC'
        WHEN ch.ctype IN (152)
        THEN 'LSV PLUS'
        WHEN ch.ctype IN (178)
        THEN 'DD'
        WHEN ch.ctype IN (154)
        THEN 'INV/SO'
        ELSE 'Unknown'
    END                 AS "PaymentType",
    pcc.days_before_due AS "daystopay",
    CASE p.status
        WHEN 0
        THEN 'lead'
        WHEN 1
        THEN 'active'
        WHEN 2
        THEN 'inactive'
        WHEN 3
        THEN 'temp inactive'
        WHEN 4
        THEN 'transferred'
        WHEN 5
        THEN 'duplicate'
        WHEN 6
        THEN 'prospect'
        WHEN 7
        THEN 'blocked'
        WHEN 8
        THEN 'anonymized'
        WHEN 9
        THEN 'contact'
        ELSE 'undefined'
    END                               AS "PersonStatus",
    prs.REQUESTED_AMOUNT              AS "Requestd_Amount",
    art.AMOUNT - art.UNSETTLED_AMOUNT AS "SettledAmount",
    prs.open_amount                   AS "Open amount)",
    ar.BALANCE                        AS "Balance",
    debtCall1.TXTVALUE                   debtCall1,
    debtCall2.TXTVALUE                   debtCall2,
    debtCall3.TXTVALUE                   debtCall3,
    debtComment.TXTVALUE                 debtComment
FROM
    PAY_REQUESTS pr
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
AND ar.ID = pr.ID
LEFT JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
AND p.ID = ar.CUSTOMERID
LEFT JOIN
    payment_request_specifications prs
ON
    PRS.CENTER = PR.INV_COLL_CENTER
AND PRS.ID = PR.INV_COLL_ID
AND PRS.SUBID = PR.INV_COLL_SUBID
LEFT JOIN
    AR_TRANS art
ON
    art.payreq_spec_center = prs.CENTER
AND art.payreq_spec_id = prs.ID
AND art.payreq_spec_subid = prs.SUBID
LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = art.REF_CENTER
AND invl.ID = art.REF_ID
AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    ACCOUNT_TRANS trans
ON
    trans.center = invl.account_trans_center
AND trans.id= invl.account_trans_id
AND trans.subid= invl.account_trans_subid
LEFT JOIN
    account_vat_type_group avtg
ON
    avtg.account_center = trans.credit_accountcenter
AND avtg.account_id = trans.credit_accountid
LEFT JOIN
    account_vat_type_link avtl
ON
    avtl.account_vat_type_group_id = avtg.ID
LEFT JOIN
    vat_types vt
ON
    vt.CENTER = avtl.vat_type_center
AND vt.ID = avtl.vat_type_id
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER ----Member of the company agreement
AND rel.ID = p.ID
AND rel.RTYPE = 3
AND rel.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
AND ca.id = rel.RELATIVEID
AND ca.SUBID = rel.RELATIVESUBID
LEFT JOIN
    PERSONS comp
ON
    comp.center = rel.RELATIVECENTER
AND comp.id = rel.RELATIVEID
LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.center = pr.CENTER
AND pa.id = pr.ID
AND pa.SUBID = pr.AGR_SUBID
LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.clearinghouse
LEFT JOIN
    payment_cycle_config pcc
ON
    pcc.ID = pa.payment_cycle_config_id
LEFT JOIN
    HP.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
AND email.PERSONID=p.id
AND email.name='_eClub_Email'
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall1
ON
    debtCall1.PERSONCENTER=p.center
AND debtCall1.PERSONID=p.id
AND debtCall1.name='COMM_1.DEBT CALL'
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall2
ON
    debtCall2.PERSONCENTER=p.center
AND debtCall2.PERSONID=p.id
AND debtCall2.name='COMM_2.DEBT CALL'
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall3
ON
    debtCall3.PERSONCENTER=p.center
AND debtCall3.PERSONID=p.id
AND debtCall3.name='COMM_3.DEBT CALL'
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtComment
ON
    debtComment.PERSONCENTER=p.center
AND debtComment.PERSONID=p.id
AND debtComment.name='COMM_DEBT Comment'
WHERE
    prs.CENTER IN (:Center)
AND p.status IN (:PStatus)
AND ( (
            :DStatus = 1
        AND p.BLACKLISTED != 1 )
    OR  (
            :DStatus = 2
        AND p.BLACKLISTED = 1 )
    OR  (
            :DStatus = 3 ) )
AND art.UNSETTLED_AMOUNT <> 0
AND art.AMOUNT < 0
AND pr.REQUEST_TYPE IN(1,6)
AND pr.DUE_DATE >= :DueDateFrom
AND pr.DUE_DATE <= :DueDateTo
AND ch.ctype IN (:PaymentType)
    --AND art.REF_TYPE = 'INVOICE'
ORDER BY
    p.center,
    p.id,
    prs.REF,
    invl.id,
    invl.subid,
    prs.ENTRY_TIME