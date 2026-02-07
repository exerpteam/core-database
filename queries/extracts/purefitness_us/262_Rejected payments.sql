SELECT
    p.center || 'p' || p.id AS "Person ID",
    p.external_id           AS "External ID",
    pr.req_date             AS "Return Payment  Date",
    pr.rejected_reason_code AS "Return Payment Code" ,
    pr.xfr_info             AS "Return Payment Text",
    ch.name                 AS "Clearing House Name",
    ar.balance              AS "Debt Amount",
    pr.req_amount           AS "Request Amount",
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
    END AS "Payment Request State",
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
    END                                        AS "Payment Agreement Status"
FROM
    payment_requests pr
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
    account_receivables ar
ON
    ar.CENTER = pr.CENTER
    AND ar.id = pr.ID
    AND ar.AR_TYPE = 4
JOIN
    persons p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
WHERE
    pr.STATE NOT IN (1,2,3,4,8,12,18)
    AND pr.req_date BETWEEN $$FromDate$$ AND $$ToDate$$
    AND p.center IN ($$Scope$$)
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )