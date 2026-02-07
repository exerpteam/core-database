SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID                                                                                                                                                                                                        AS member_id,
    pr.REQ_AMOUNT                                                                                                                                                                                                        AS requested_amount,
    DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manual',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed', 17, 'Failed, payment revoked', 18, 'Done Partial', 19, 'Failed, Unsupported', 20, 'Require approval', 21,'Fail, debt case exists', 22,' Failed, timed out','UNDEFINED') AS request_state,
    pr.REQ_DELIVERY AS payment_export_File,
    pr.REQ_DATE AS request_date                                                                                                                                                                                                         
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.center
    AND ar.id = pr.id
    AND ar.AR_TYPE = 4
WHERE
    pr.EMPLOYEE_CENTER = 100
    AND pr.EMPLOYEE_ID = 30099