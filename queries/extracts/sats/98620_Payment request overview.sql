-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            (:from_date)::DATE AS fromDate,
            (:to_date)::DATE   AS toDate
    )
SELECT
 
    CASE REQUEST_TYPE
        WHEN 1
        THEN 'Payment'
        WHEN 2
        THEN 'Debt Collection'
        WHEN 3
        THEN 'Reversal'
        WHEN 4
        THEN 'Reminder'
        WHEN 5
        THEN 'Refund'
        WHEN 6
        THEN 'Representation'
        WHEN 7
        THEN 'Legacy'
        WHEN 8
        THEN 'Zero'
        WHEN 9
        THEN 'Service Charge'
        ELSE 'Undefined'
    END AS Request_Type,
    (
        CASE pr.STATE
            WHEN 1
            THEN 'New'
            WHEN 2
            THEN 'Sent'
            WHEN 3
            THEN 'Done'
            WHEN 4
            THEN 'Done, manual'
            WHEN 5
            THEN 'Rejected, clearinghouse'
            WHEN 6
            THEN 'Rejected, bank'
            WHEN 7
            THEN 'Rejected, debtor'
            WHEN 8
            THEN 'Cancelled'
            WHEN 10
            THEN 'Reversed, new'
            WHEN 11
            THEN 'Reversed , sent'
            WHEN 12
            THEN 'Failed, not creditor/ could not be sent'
            WHEN 13
            THEN 'Reversed, rejected'
            WHEN 14
            THEN 'Reversed, confirmed'
            WHEN 17
            THEN 'Failed, payment revoked'
            WHEN 18
            THEN 'Done Partial'
            WHEN 19
            THEN 'Failed, Unsupported'
            WHEN 20
            THEN 'Require approval'
            WHEN 21
            THEN 'Fail, debt case exists'
            WHEN 22
            THEN 'Failed, timed out'
            ELSE 'Undefined'
        END) AS Request_State,
    pr.xfr_info,
    pr.clearinghouse_id AS clearinghouse_id,
    ch.name             AS clearinghouse_name,
    c.country,
    SUM(pr.req_amount) AS total_amount,
    COUNT(pr.center)   AS amount_pr
FROM
    sats.payment_requests pr
CROSS JOIN
    params par
JOIN
    sats.centers c
ON
    pr.center = c.id
JOIN
    sats.clearinghouses ch
ON
    pr.clearinghouse_id = ch.id
WHERE
    pr.req_date >= par.fromDate
AND pr.req_date <= par.toDate
AND ch.ctype IN (184,2,1)
GROUP BY
    pr.request_type,
    pr.clearinghouse_id,
    pr.state,
    ch.name,
    c.country,
    pr.xfr_info
UNION ALL
SELECT

    CASE REQUEST_TYPE
        WHEN 1
        THEN 'Payment'
        WHEN 2
        THEN 'Debt Collection'
        WHEN 3
        THEN 'Reversal'
        WHEN 4
        THEN 'Reminder'
        WHEN 5
        THEN 'Refund'
        WHEN 6
        THEN 'Representation'
        WHEN 7
        THEN 'Legacy'
        WHEN 8
        THEN 'Zero'
        WHEN 9
        THEN 'Service Charge'
        ELSE 'Undefined'
    END AS Request_Type,
    (
        CASE pr.STATE
            WHEN 1
            THEN 'New'
            WHEN 2
            THEN 'Sent'
            WHEN 3
            THEN 'Done'
            WHEN 4
            THEN 'Done, manual'
            WHEN 5
            THEN 'Rejected, clearinghouse'
            WHEN 6
            THEN 'Rejected, bank'
            WHEN 7
            THEN 'Rejected, debtor'
            WHEN 8
            THEN 'Cancelled'
            WHEN 10
            THEN 'Reversed, new'
            WHEN 11
            THEN 'Reversed , sent'
            WHEN 12
            THEN 'Failed, not creditor'
            WHEN 13
            THEN 'Reversed, rejected'
            WHEN 14
            THEN 'Reversed, confirmed'
            WHEN 17
            THEN 'Failed, payment revoked'
            WHEN 18
            THEN 'Done Partial'
            WHEN 19
            THEN 'Failed, Unsupported'
            WHEN 20
            THEN 'Require approval'
            WHEN 21
            THEN 'Fail, debt case exists'
            WHEN 22
            THEN 'Failed, timed out'
            ELSE 'Undefined'
        END)            AS Request_State,
    NULL                AS xfr_info,
    pr.clearinghouse_id AS clearinghouse_id,
    ch.name             AS clearinghouse_name,
    c.country,
    SUM(pr.req_amount) AS total_amount,
    COUNT(pr.center)   AS amount_pr
FROM
    sats.payment_requests pr
CROSS JOIN
    params par
JOIN
    sats.centers c
ON
    pr.center = c.id
JOIN
    sats.clearinghouses ch
ON
    pr.clearinghouse_id = ch.id
WHERE
    pr.req_date >= par.fromDate
AND pr.req_date <= par.toDate
AND ch.ctype NOT IN (184,2,1)
GROUP BY
    pr.request_type,
    pr.clearinghouse_id,
    pr.state,
    ch.name,
    c.country
ORDER BY
    6,2,
    3