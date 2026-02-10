-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8560
SELECT DISTINCT
    p.external_id,
    p.center || 'p' || p.id AS PersonId,
    cen.id   AS CLUB_ID ,
    cen.NAME AS "CENTER NAME" ,
    pp.CENTER || 'p' || pp.id "PAYER ID" ,
    pp.FULLNAME "PAYER NAME" ,
    p.FULLNAME                   AS "MEMBER NAME" ,
    pag.INDIVIDUAL_DEDUCTION_DAY AS "NORMAL DD DAY" ,
    longToDateC(s.CREATION_TIME,s.CENTER) "Sales date" ,
    prod.NAME "SUBSCRIPTION NAME" ,
    TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') INIT_COLL_DATE ,
    prs.REQUESTED_AMOUNT                         INIT_AMOUNT ,
    CASE pr.REQUEST_TYPE
        WHEN 1
        THEN 'PAYMENT'
        WHEN 5
        THEN 'REFUND'
        WHEN 1
        THEN 'REPRESENTATION'
        WHEN 5
        THEN 'ZERO'
        ELSE 'UNKNOWN'
    END                                AS type,
    TO_CHAR(pr.DUE_DATE, 'YYYY-MM-DD')    COLLECTION_DATE ,
    pr.REQ_AMOUNT                         SENT_AMOUNT ,
    pr.XFR_INFO "Rejection Reason Code" ,
    pag.BANK_ACCOUNT_HOLDER AS ACCOUNT_HOLDER_NAME ,
    CASE
        WHEN LENGTH(pag.ref) > 14
        THEN pag.ref
        ELSE rpad(pag.ref, 14, ' ') || pr.ref
    END     AS PR_BACS_REF ,
    pag.ref AS BACS_REF ,
    CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
        ELSE 'UNDEFINED'
    END                                       AS "PaymentAgreementState",
    cli.id                                    AS REJECTION_FILE_ID ,
    TO_CHAR(cli.GENERATED_DATE, 'YYYY-MM-DD') AS ADVICE_DATE ,
    CASE
        WHEN first_value(acl.STATE) over (partition BY acl.AGREEMENT_CENTER,acl.AGREEMENT_ID,acl.AGREEMENT_SUBID ORDER BY acl.LOG_DATE ASC) IN (3,5,6,7,8,9,10)
        THEN 1
        ELSE 0
    END     AS "DD ENDED BEFORE REPRESENTATION",
    ch.name AS clearinghouseName
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
    AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = pag.CENTER
    AND acl.AGREEMENT_ID = pag.id
    AND acl.AGREEMENT_SUBID = pag.SUBID
    AND acl.ENTRY_TIME < pr.ENTRY_TIME
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pag.center
    AND ar.id = pag.id
JOIN
    PERSONS pp
ON
    pp.CENTER = ar.CUSTOMERCENTER
    AND pp.id = ar.CUSTOMERID
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.center = pr.INV_COLL_CENTER
    AND prs.id = pr.INV_COLL_ID
    AND prs.subid = pr.INV_COLL_SUBID
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
    invoice_lines_mt invl
ON
    invl.CENTER = art.REF_CENTER
    AND invl.ID = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.id = invl.PRODUCTID
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = prod.CENTER
    AND st.id = prod.ID
JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = invl.PERSON_CENTER
    AND s.OWNER_ID = invl.PERSON_ID
    AND s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
JOIN
    persons p
ON
    p.center = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    CLEARING_IN cli
ON
    cli.ID = pr.XFR_DELIVERY
JOIN
    CENTERS cen
ON
    cen.ID = P.CENTER
WHERE
    pr.XFR_DATE >= $$From_Date$$
    AND pr.XFR_DATE <= $$To_Date$$
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )