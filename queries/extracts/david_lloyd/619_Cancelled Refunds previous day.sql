-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS MATERIALIZED
    (   SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')-interval '1 days',
            'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'),
            'YYYY-MM-DD'), c.id) AS BIGINT) AS toDate,
            c.id                            AS centerid,
            c.name
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
SELECT
    p.external_id           AS "Member ID",
    p.center || 'p' || p.id AS "Personkey",
    p.fullname              AS "Fullname",
    TO_CHAR(longtodateC(prs.paid_state_last_entry_time, prs.center), 'DD/MM/YYYY HH:MI:SS AM') AS "Cancellation time",
    par.name AS "Center",
    prs.requested_amount*-1 AS "Refund amount"
FROM
    payment_request_specifications prs
    JOIN
    params par
    ON
    par.centerId = prs.center
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
WHERE
pr.request_type = 5
AND p.sex != 'C'
AND pr.state = 8
AND pr.clearinghouse_id IN (2)
AND prs.paid_state = 'CANCELLED'
AND prs.paid_state_last_entry_time BETWEEN par.fromDate AND par.toDate