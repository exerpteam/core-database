-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-12494
SELECT
        ccc.PERSONCENTER || 'p' || ccc.PERSONID AS "PERSON_ID",
        ar.BALANCE AS "TOTAL_DEBT",        DECODE(ar.AR_TYPE,1,'CASH_ACCOUNT',4,'PAYMENT_ACCOUNT',5,'EXTERNAL_DEBT_ACCOUNT',6,'installment') as ACCOUNT_TYPE,
        prs.REF AS "INVOICE_REF",
        pr.REQ_DATE AS "TEXT",
        pag.REF as "PAYMENT_REF",
        pag.EXAMPLE_REFERENCE AS "PAYMENT_REF_2",
        pr.REQ_DATE AS "REQ_DATE",
        pr.DUE_DATE AS "DUE_DATE",
        pr.REQ_AMOUNT AS "ORIGINAL_AMOUNT",
        ccr.REQ_AMOUNT AS "CCR_REQ_AMOUNT",
        art.UNSETTLED_AMOUNT AS "OPEN_AMOUNT_TRANSACTION",
        ccc.STARTDATE AS "DEBT_CASE_START_DATE",
        ccc.AMOUNT AS CCC_AMOUNT,
        ccc.CENTER || 'ccol' || ccc.ID AS CCC_ID,
        ccr.CENTER  || 'ccol' ||ccr.ID || 'r' || ccr.SUBID AS CCR_ID,
        ccr.REQ_DELIVERY AS FILE_ID,
        ccr.REF AS CCR_REF,
        ccr.REQ_AMOUNT AS CCR_REQ_AMOUNT,
        ccr.PRSCENTER || 'ar' || ccr.PRSID || 'sp' || ccr.PRSSUBID AS PAYMENT_REQUEST_SPEC_ID,
        ccr.PAYMENT_REQUEST_CENTER || 'ar' || ccr.PAYMENT_REQUEST_ID || 'req' || ccr.PAYMENT_REQUEST_SUBID AS PAYMENT_REQUEST_ID,
        art.CENTER || 'ar' || art.ID || 'art' || art.SUBID AS TRANSACTION_ID,
        art.AMOUNT AS TRANSACTION_AMOUNT,
        art.TEXT AS TRANSACTION_TEXT,
        art.STATUS AS TRANSACTION_STATUS
FROM 
        FW.CASHCOLLECTION_REQUESTS ccr
JOIN
        FW.CASHCOLLECTIONCASES ccc 
                ON ccr.CENTER = ccc.CENTER AND ccr.ID = ccc.ID
JOIN
        FW.PAYMENT_REQUEST_SPECIFICATIONS prs
                ON prs.CENTER = ccr.PRSCENTER AND prs.ID = ccr.PRSID AND prs.SUBID = ccr.PRSSUBID
JOIN 
        FW.PAYMENT_REQUESTS pr 
                ON pr.INV_COLL_CENTER = prs.CENTER AND pr.INV_COLL_ID = prs.ID AND pr.INV_COLL_SUBID = prs.SUBID
JOIN
        FW.AR_TRANS art
                ON art.PAYREQ_SPEC_CENTER = prs.CENTER AND art.PAYREQ_SPEC_ID = prs.ID AND art.PAYREQ_SPEC_SUBID = prs.SUBID
JOIN
        FW.ACCOUNT_RECEIVABLES ar
                ON ar.CENTER = art.CENTER AND ar.ID = art.ID
JOIN
        FW.PAYMENT_AGREEMENTS pag
                ON pag.CENTER = pr.CENTER AND pag.ID = pr.ID AND pag.SUBID = pr.AGR_SUBID
WHERE
        ccr.REQ_DELIVERY IN (66207,65811,65812,65604,65808,66205,65810,65807,66402,65809,66206,66005,65603,65803,66202,66203,65806,66401,65805,65804,65802,66204,66002)
        AND art.UNSETTLED_AMOUNT != 0

        AND ccr.CENTER IN (:Scope)