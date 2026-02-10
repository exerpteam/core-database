-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date(getcentertime(c.id), 'YYYY-MM-DD') AS cutDate,
            c.ID                                       AS CenterID
        FROM
            CENTERS c
        JOIN
            COUNTRIES co
        ON
            c.COUNTRY = co.ID
    )
SELECT
    p.external_id                         AS "External ID",
    p.center || 'p' || p.id               AS "Person ID",
    prs.original_due_date                 AS "Original Due Date",
    rep_req.due_date                      AS "Representation due date",
    prs.requested_amount                  AS "Request amount",
    pag.ref                               AS "Reference",
    pr.xfr_info                           AS "Reason",
    pr.rejected_reason_code               AS "Reject Reason Code",
    longtodateC(pr.entry_time, pr.center) AS "Failed date",
    fee.total_amount                      AS "Admin fee",
    ch.name                               AS "Clearing House"
FROM
    payment_request_specifications prs
JOIN
    params
ON
    params.CenterID = prs.center
JOIN
    account_receivables ar
ON
    ar.center = prs.center
    AND ar.id = prs.id
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
JOIN
    payment_requests pr
ON
    prs.center = pr.inv_coll_center
    AND prs.id = pr.inv_coll_id
    AND prs.subid = pr.inv_coll_subid
    AND pr.request_type = 1
    AND pr.state NOT IN (1,2,3,4,8,12,18)
JOIN
    clearinghouses ch
ON
    ch.id = pr.clearinghouse_id
JOIN
    payment_accounts pac
ON
    pac.center = ar.center
    AND pac.id = ar.id
JOIN
    payment_agreements pag
ON
    pag.center = pac.active_agr_center
    AND pag.id = pac.active_agr_id
    AND pag.subid = pac.active_agr_subid
LEFT JOIN
    payment_requests rep_req
ON
    rep_req.inv_coll_center = prs.center
    AND rep_req.inv_coll_id = prs.id
    AND rep_req.inv_coll_subid = prs.subid
    AND rep_req.request_type = 6
    AND rep_req.state NOT IN (8)
LEFT JOIN
    invoice_lines_mt fee
ON
    pr.reject_fee_invline_center = fee.center
    AND pr.reject_fee_invline_id = fee.id
    AND pr.reject_fee_invline_subid = fee.subid
WHERE
    --4) The member still has overdue debt on their account
    ar.balance < 0
    -- 7 days after the collection date of the failed payment.
    AND pr.due_date = params.cutDate - 7
    AND ar.ar_type = 4
    AND pr.xfr_info IN ('Not enough balance',
                        'Refused',
                        'Issuer Unavailable',
                        'Pin tries exceeded',
                        'Transaction Not Permitted',
                        'Withdrawal amount exceeded',
                        'Withdrawal count exceeded',
                        'Acquirer Error',
                        'Declined Non Generic',
                        'Expired Card')
    AND p.sex != 'C'
    AND pag.state = 4 -- OK
    AND pr.center IN ($$Scope$$)