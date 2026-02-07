WITH params AS (
    SELECT
        datetolongC('2024-07-01 00:00', c.id) AS FromDatelong,
        c.id AS center_id
    FROM centers c
),

filtered_invoices AS (
    SELECT inv.*, invl.total_amount AS invl_total_amount, invl.center AS invl_center, invl.id AS invl_id, inv.text AS Description
    FROM fernwood.invoices inv
    JOIN fernwood.invoice_lines_mt invl ON inv.center = invl.center AND inv.id = invl.id
    JOIN params ON inv.center = params.center_id
    WHERE inv.center IN (:Scope)
      AND inv.trans_time >= params.FromDatelong
      AND invl.total_amount != 0
),

filtered_trans AS (
    SELECT act.*, accr.customercenter, accr.customerid, act.text AS Description
    FROM fernwood.account_trans act
    JOIN fernwood.account_receivables accr ON act.center = accr.center AND act.id = accr.id AND accr.ar_type = 4
    JOIN params ON act.center = params.center_id
    WHERE act.center IN (:Scope)
      AND act.trans_type = 2
      AND act.info_type != 3
      AND act.entry_time >= params.FromDatelong
      AND act.amount != 0
),

settlements AS (
    SELECT
        arm.art_paid_center, arm.art_paid_id, arm.art_paid_subid,
        arm.art_paying_center, arm.art_paying_id, arm.art_paying_subid,
        arm.entry_time AS settlement_time,
        arm.amount,
        arm.cancelled_time
    FROM art_match arm
    WHERE arm.cancelled_time IS NULL
),

invoice_data AS (
    SELECT
        inv.payer_center || 'p' || inv.payer_id AS PersonID,
        c.name AS club,
        p.firstname,
        p.lastname,
        inv.Description,
        COALESCE(-art.unsettled_amount, 0) AS "Outstanding amount",
        inv.center || 'inv' || inv.id AS invoice_id,
        longtodatec(inv.trans_time, inv.center) AS invoice_date,
        art.due_date,
        inv.invl_total_amount AS "Original Amount"
    FROM filtered_invoices inv
    LEFT JOIN fernwood.ar_trans art ON art.ref_center = inv.invl_center AND art.ref_id = inv.invl_id
    LEFT JOIN settlements arm ON art.center = arm.art_paid_center AND art.id = arm.art_paid_id AND art.subid = arm.art_paid_subid
    LEFT JOIN fernwood.persons p ON p.center = inv.payer_center AND p.id = inv.payer_id
    LEFT JOIN centers c ON c.id = inv.center
    WHERE (art.due_date IS NOT NULL OR art.due_date IS NULL AND art.status = 'SUSPENDED')
),

installment_data AS (
    SELECT
        accr.customercenter || 'p' || accr.customerid AS PersonID,
        c.name AS club,
        p.firstname,
        p.lastname,
        act.Description,
        COALESCE(-art.unsettled_amount, 0) AS "Outstanding amount",
        act.center || 'acc' || act.id || 'tr' || act.subid AS invoice_id,
        longtodatec(act.entry_time, act.center) AS invoice_date,
        art.due_date,
        act.amount AS "Original Amount"
    FROM filtered_trans act
    JOIN fernwood.ar_trans art ON art.ref_center = act.center AND art.ref_id = act.id AND art.ref_subid = act.subid
    LEFT JOIN settlements arm ON art.center = arm.art_paid_center AND art.id = arm.art_paid_id AND art.subid = arm.art_paid_subid
    JOIN fernwood.account_receivables accr ON accr.center = art.center AND accr.id = art.id
    LEFT JOIN fernwood.persons p ON p.center = accr.customercenter AND p.id = accr.customerid
    LEFT JOIN centers c ON c.id = act.center
    WHERE (art.due_date IS NOT NULL OR art.due_date IS NULL AND art.status = 'SUSPENDED')
)

SELECT
    t.PersonID,
    t.club,
    t.firstname,
    t.lastname,
    t.Description,
    t."Outstanding amount",
    t.invoice_date,
    t.due_date,
    t."Original Amount"
FROM (
    SELECT * FROM invoice_data
    UNION ALL
    SELECT * FROM installment_data
) t
WHERE
    t."Outstanding amount" != 0
    AND (LOWER(t.Description) LIKE '%hypoxi%' OR LOWER(t.Description) LIKE '%hdc%')
    AND t.Description NOT IN ('Rejection Fee', 'Rejection Fee - Missing Payment Agreement')
    AND t.due_date < CURRENT_DATE - 6
    AND t.due_date < CURRENT_DATE
ORDER BY t.PersonID, t.invoice_date;
