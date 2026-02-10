-- The extract is extracted from Exerp on 2026-02-08
-- The script  identifies any payment requests in state "new" with a payment request type "refund" with bank information missing, that could be causing refund files to fail.
SELECT
    pr.center, pr.id, pr.subid, pr.req_amount, pr.req_date
FROM
    payment_requests pr
JOIN
    payment_agreements pag on pag.center = pr.center and pag.id = pr.id and pag.subid = pr.agr_subid
WHERE
    pr.state = 1 --New
AND
    pr.request_type = 5 --Refund
AND
    pag.bank_accno is null