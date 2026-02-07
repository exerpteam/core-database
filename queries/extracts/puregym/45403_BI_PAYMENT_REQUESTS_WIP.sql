SELECT
    pr.center||'pr'||pr.id||'id'|| pr.SUBID                                                                                                                                                                                                        AS "PAYMENT_REQUEST_ID",
    cp.EXTERNAL_ID                                                                                                                                                                                                        AS "PERSON_ID",
    DECODE(pr.REQUEST_TYPE,1,'PAYMENT',6,'REPRESENTATION',8,'ZERO','UNDEFINED')                                                                                                                                                                                                        AS "TYPE",
    UPPER(DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17, 'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20, 'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out','UNDEFINED')) AS "STATE",
    pr.REQ_AMOUNT                                                                                                                                                                                                        AS "AMOUNT" ,
    TO_CHAR(pr.DUE_DATE,'yyyy-MM-dd')                                                                                                                                                                                                        AS "DUE_DATE",
    CASE
        WHEN pr.XFR_AMOUNT IS NULL
        THEN 0
        ELSE pr.XFR_AMOUNT
    END                                                                AS "RECEIVED_AMOUNT",
    pr.XFR_INFO                                                        AS "INFO",
    pr.INV_COLL_CENTER||'prs'||pr.INV_COLL_ID||'id'||pr.INV_COLL_SUBID AS "REQUEST_SPEC_ID",
    CASE
        WHEN prs.CANCELLED = 1
        THEN 'true'
        WHEN prs.CANCELLED = 0
        THEN 'false'
    END                                                                                              AS "SPEC_CANCELLED",
    pr.center||'pa'||pr.id||'id'||pr.AGR_SUBID                                                       AS "PAYMENT_AGREEMENT_ID",
    pr.COLL_FEE_INVLINE_CENTER||'inv'||pr.COLL_FEE_INVLINE_ID||'il'||pr.COLL_FEE_INVLINE_SUBID       AS "COLLECTION_SALES_LINE_ID",
    pr.REJECT_FEE_INVLINE_CENTER||'inv'||pr.REJECT_FEE_INVLINE_ID||'il'||pr.REJECT_FEE_INVLINE_SUBID AS "REJECTION_SALES_LINE_ID",
    pr.LAST_MODIFIED                                                                                 AS "ETS"
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
    AND ar.AR_TYPE = 4
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    PERSONS cp
ON
    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    prs.CENTER = pr.INV_COLL_CENTER
    AND prs.id = pr.INV_COLL_ID
    AND prs.SUBID = pr.INV_COLL_SUBID
WHERE
    pr.XFR_INFO IS NOT NULL
    --    AND pr.XFR_INFO !='Done by batchjob'