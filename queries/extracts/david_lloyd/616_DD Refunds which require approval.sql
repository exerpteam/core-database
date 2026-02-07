-- This is the version from 2026-02-05
--  
SELECT
    p.external_id               AS "Member ID",
    p.center || 'p' || p.id     AS "Personkey",
    p.fullname                  AS "Fullname",
    prs.open_amount             AS "Refund amount",
    emp.center ||'emp'|| emp.id AS "Staff ID",
    staff.fullname              AS "Staff fullname"
FROM
    payment_request_specifications prs
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
JOIN
    employees emp
ON
    emp.center = pr.employee_center
AND emp.id = pr.employee_id
JOIN
    persons staff
ON
    staff.center = emp.personcenter
AND staff.id = emp.personid
WHERE
    pr.request_type = 5
AND p.sex != 'C'
AND pr.state = 20
AND pr.clearinghouse_id IN (2)
AND prs.open_amount < 0
AND p.center IN (:scope)