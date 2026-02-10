-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    to_timestamp(acl.entry_time / 1000) AS "Entry Date",
    CASE
        WHEN acl.state = 4
        THEN 'OK'
        ELSE acl.state::text
    END AS "Status",
    CASE
        WHEN pag.agreement_completion_method = 'SEND_EMAIL'
        THEN 'WEB'
        WHEN pag.agreement_completion_method = 'CARD_TERMINAL'
        THEN 'CLIENT'
        ELSE pag.agreement_completion_method
    END                                             AS "Text",
    acl.employee_center || 'emp' || acl.employee_id AS "Employee ID",
    CASE
        WHEN p.external_id IS NOT NULL
        THEN p.center || 'p' || p.id
        ELSE
              (
              SELECT
                  p2.center || 'p' || p2.id
              FROM
                  persons p2
              WHERE
                  p2.center = p.transfers_current_prs_center
              AND p2.id = p.transfers_current_prs_id LIMIT 1)
    END AS "P number",
    CASE
        WHEN p.external_id IS NOT NULL
        THEN p.external_id
        ELSE
              (
              SELECT
                  p2.external_id
              FROM
                  persons p2
              WHERE
                  p2.center = p.transfers_current_prs_center
              AND p2.id = p.transfers_current_prs_id LIMIT 1)
    END AS "External ID"
FROM
    agreement_change_log acl
JOIN
    payment_agreements pag
ON
    acl.agreement_center = pag.center
AND acl.agreement_id = pag.id
AND acl.agreement_subid = pag.subid
JOIN
    payment_accounts pac
ON
    pac.active_agr_center = pag.center
AND pac.active_agr_id = pag.id
AND pac.active_agr_subid = pag.subid
JOIN
    account_receivables ar
ON
    ar.center = pac.center
AND ar.id = pac.id
JOIN
    persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
    acl.state = 4
AND pag.clearinghouse = 201
AND (
        pag.agreement_completion_method = 'SEND_EMAIL'
    OR  pag.agreement_completion_method = 'CARD_TERMINAL')
AND to_timestamp(acl.entry_time / 1000) >= to_timestamp(:date_from, 'YYYY-MM-DD')
AND to_timestamp(acl.entry_time / 1000) <= to_timestamp(:date_to, 'YYYY-MM-DD');