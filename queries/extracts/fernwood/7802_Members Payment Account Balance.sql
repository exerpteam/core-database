WITH unsettled_trans AS (
    SELECT 
        center,
        id,
        SUM(unsettled_amount) AS total_unsettled
    FROM fernwood.ar_trans
    WHERE status != 'CLOSED'
      AND due_date < current_date
    GROUP BY center, id
)

SELECT
    c.name AS "Club Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    ar.balance AS "Account Balance",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transfered'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    COALESCE(ut.total_unsettled, 0) AS "Overdue/Outstanding Amount",
    CASE  
        WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
        WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
        ELSE 'FF_Invoice'
    END AS "Payment Cycle",
    'Payment Account' AS "Account Type"
FROM 
    fernwood.persons p
JOIN fernwood.centers c 
    ON c.id = p.center
JOIN fernwood.account_receivables ar 
    ON p.center = ar.customercenter 
    AND p.id = ar.customerid 
    AND ar.ar_type = 4
    AND ar.balance != 0
LEFT JOIN unsettled_trans ut 
    ON ut.center = ar.center 
    AND ut.id = ar.id
LEFT JOIN fernwood.payment_accounts pac 
    ON pac.center = ar.center 
    AND pac.id = ar.id
LEFT JOIN fernwood.payment_agreements pag 
    ON pac.active_agr_center = pag.center 
    AND pac.active_agr_id = pag.id 
    AND pac.active_agr_subid = pag.subid
WHERE 
    p.center IN (:Scope)
