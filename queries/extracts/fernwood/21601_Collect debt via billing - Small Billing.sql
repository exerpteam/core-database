-- The extract is extracted from Exerp on 2026-02-08
-- 
WITH
    open_invoices AS
        (
            SELECT
                longtodatec(inv.trans_time, inv.center) AS transaction_time,
                inv.payer_center,
                inv.payer_id
            FROM
                invoices inv
            JOIN
                ar_trans art
                ON inv.center = art.ref_center
                AND inv.id = art.ref_id
                AND art.ref_type = 'INVOICE'
            JOIN
                invoice_lines_mt invl
                ON inv.center = invl.center
                AND inv.id = invl.id
            WHERE
                art.status IN ('NEW', 'OPEN')
                AND art.due_date IS NULL
                AND invl.reason = 9
        )
SELECT
    p.fullname AS Member_name,
    p.center || 'p' || p.id AS Person_ID,
    CASE
        WHEN pag.individual_deduction_day = 4 THEN 'Small Billing'
        WHEN pag.individual_deduction_day = 11 THEN 'Big Billing'
        ELSE 'Check'
    END AS payment_cycle,
    ar.balance AS account_balance,
    s.billed_until_date AS Subscription_billed_until_date,
    s.end_date AS Subscription_end_date,
    longtodatec(ar.collected_until, ar.center) AS payment_account_last_collection
FROM
    persons p
JOIN
    subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.state IN (2, 4)
LEFT JOIN
    open_invoices
    ON open_invoices.payer_center = p.center
    AND open_invoices.payer_id = p.id
JOIN
    account_receivables ar
    ON p.center = ar.customercenter
    AND p.id = ar.customerid
    AND ar.ar_type = 4
    AND ar.balance < 0
JOIN
    payment_agreements pag
    ON ar.center = pag.center
    AND ar.id = pag.id
    AND pag.state IN (1, 4)
    AND pag.active IS TRUE
WHERE
    open_invoices.payer_center IS NULL
    AND pag.individual_deduction_day = 4 -- Filter for Small Billing
