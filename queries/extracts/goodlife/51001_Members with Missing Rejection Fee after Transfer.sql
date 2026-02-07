SELECT
    ar.customercenter||'p'||ar.customerid AS member,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
CASE preq.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state,
    preq.rejected_reason_code,
    preq.req_amount,
    preq.req_date AS request_date,
    preq.xfr_date AS request_transfer_date,
    preq.agr_subid ,
    pa.creditor_id
    --    ,preq.*
FROM
    payment_requests preq
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    preq.center = ar.center
AND preq.id = ar.id
AND ar.ar_type = 4
JOIN
    persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
    goodlife.payment_agreements pa
ON
    preq.center = pa.center
AND preq.id = pa.id
AND preq.agr_subid = pa.subid
WHERE
    p.status = 4 -- transferred
AND preq.state NOT IN (1, --New
                       2, --Sent
                       3, --Done
                       4, --Done, manual
                       7, --Rejected, debtor
                       8, --Cancelled
                       12) --Failed, not creditor/ could not be sent
AND preq.REJECTED_REASON_CODE IN ('01',
                                  '08')
AND preq.xfr_date::DATE - preq.req_date::DATE < 2
AND preq.reject_fee_invline_center IS NULL
AND preq.req_date > DATE 'today' - $$offset$$ -- for extract in exerp
--AND preq.req_date > DATE 'today' - ${offset}$ --For DBVIS
    --preq.req_date > '2025-01-01'
AND preq.REQUEST_TYPE = 1 --payment