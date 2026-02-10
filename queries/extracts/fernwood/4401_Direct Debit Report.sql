-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-10297
SELECT
    c.shortname AS "Club Name",
    CASE
        WHEN p.external_id IS NULL
        THEN tp.external_id
        ELSE p.external_id
    END           AS "Member ID",
    pet.txtvalue  AS "Old System ID",
    p.fullname    AS "Member Name",
    pr.req_amount AS "Debit Amount",
    pr.req_date   AS "Deduction Date"
,CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state
FROM
    payment_requests pr
JOIN
    account_receivables ar
ON
    pr.center = ar.center
    AND pr.id = ar.id
JOIN
    centers c
ON
    c.ID = pr.center
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
LEFT JOIN
    persons tp
ON
    p.transfers_current_prs_center = tp.center
    AND p.transfers_current_prs_id = tp.id
LEFT JOIN
    person_ext_attrs pet
ON
    pet.personcenter = p.center
    AND pet.personid = p.id
    AND pet.name = '_eClub_OldSystemPersonId'
WHERE
    pr.req_date >= $$from_date$$
    AND pr.req_date <= $$to_date$$
    AND pr.center IN ($$scope$$)