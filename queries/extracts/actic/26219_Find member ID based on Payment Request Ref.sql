-- The extract is extracted from Exerp on 2026-02-08
-- Find member ID based on Payment Request Ref
SELECT
    pr.REF                                                                                                                                                                                                        AS terminal_Reference_Number ,
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID                                                                                                                                                                                                        AS MEMBER_ID,
    p.NAME                                                                                                                                                                                                        AS PRODUCT_NAME,
    s.START_DATE                                                                                                                                                                                                        AS SUBSCRIPTION_START_DATE,
    s.END_DATE                                                                                                                                                                                                        AS SUBSCRIPTION_END_DATE,
    s.BILLED_UNTIL_DATE                                                                                                                                                                                                        AS BILLED_UNTIL_DATE,
    DECODE (s.state, 2,'Active', 3,'Ended', 4,'Frozen', 7,'Window', 8,'Created','Unknown')                                                                                                                                                                                                        AS SUBSCRIPTION_STATE,
    pr.REQ_AMOUNT                                                                                                                                                                                                        AS REQUESTED_AMOUNT,
    invl.TOTAL_AMOUNT                                                                                                                                                                                                        AS INVOICE_LINE_AMOUNT,
    DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17, 'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20, 'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out','UNDEFINED') AS PAYMENT_REQUEST_STATE,
    pr.REJECTED_REASON_CODE                                                                                                                                                                                                        AS RESPONSE_CODE,
    invl.TEXT                                                                                                                                                                                                        AS INVOICE_LINE_TEST
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    pr.center = ar.center
    AND pr.id = ar.id
    AND ar.AR_TYPE = 4
JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = pr.INV_COLL_CENTER
    AND art.PAYREQ_SPEC_ID = pr.INV_COLL_ID
    AND art.PAYREQ_SPEC_SUBID = pr.INV_COLL_SUBID
JOIN
    INVOICE_LINES_MT invl
ON
    invl.center = art.REF_CENTER
    AND invl.id = art.REF_ID
    AND art.REF_TYPE = 'INVOICE'
LEFT JOIN
    PRODUCTS p
ON
    p.CENTER = invl.PRODUCTCENTER
    AND p.id = invl.PRODUCTID
LEFT JOIN
    products p2
ON
    p2.center = p.center
    AND p2.GLOBALID = 'CREATION_'||p.GLOBALID
LEFT JOIN
    SUBSCRIPTIONTYPES st
ON
    st.PRODUCTNEW_CENTER = p2.center
    AND st.PRODUCTNEW_ID = p2.id
LEFT JOIN
    SUBSCRIPTIONS s
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
    AND s.OWNER_CENTER = ar.CUSTOMERCENTER
    AND s.OWNER_ID = ar.CUSTOMERID
WHERE
    pr.REF IN (:terminalReferenceNumber)