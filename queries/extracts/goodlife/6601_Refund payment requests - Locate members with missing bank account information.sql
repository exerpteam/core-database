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