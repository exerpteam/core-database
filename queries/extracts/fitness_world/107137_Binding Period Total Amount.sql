-- This is the version from 2026-02-05
--  
WITH initial_group AS
(
    SELECT
        t1.center,
        t1.id,
        t1.owner_center,
        t1.owner_id,
        t1.subscription_price,
        (CASE spp.spp_type
            WHEN 1 THEN 'NORMAL'
            WHEN 2 THEN 'FREEZE'
            WHEN 3 THEN 'FREE DAYS'
            WHEN 7 THEN 'CONDITIONAL FREEZE'
            WHEN 8 THEN 'INITIAL PERIOD'
            WHEN 9 THEN 'PRORATA PERIOD'
        END) AS spptype,
        t1.binding_end_date,
        t1.billed_until_date,
        il.total_amount AS paid_amount,
        MIN(spp.from_date) OVER (PARTITION BY t1.center, t1.id, t1.owner_center, t1.owner_id ORDER BY t1.center) AS min_spp,
        MAX(spp.to_date) OVER (PARTITION BY t1.center, t1.id, t1.owner_center, t1.owner_id ORDER BY t1.center) AS max_spp
    FROM
    (
        SELECT
            s.center,
            s.id,
            s.owner_center,
            s.owner_id,
            s.binding_end_date,
            s.subscription_price,
            s.billed_until_date,
            rank() OVER (PARTITION BY s.owner_center, s.owner_id ORDER BY s.creation_time DESC) AS ranking
        FROM subscriptions s
        WHERE
            s.state IN (2, 4, 8)
            AND (s.owner_center, s.owner_id) IN (:PersonId)
    ) t1
    JOIN fw.subscriptionperiodparts spp
        ON spp.center = t1.center AND spp.id = t1.id
    JOIN fw.spp_invoicelines_link sppil
        ON sppil.period_center = spp.center AND sppil.period_id = spp.id AND sppil.period_subid = spp.subid
    JOIN fw.invoice_lines_mt il
        ON sppil.invoiceline_center = il.center AND sppil.invoiceline_id = il.id AND sppil.invoiceline_subid = il.subid
    JOIN fw.products pr
        ON pr.center = il.productcenter AND pr.id = il.productid
    WHERE 
        ranking = 1
        AND (spp.cancellation_time IS NULL OR spp.cancellation_time = 0)
        AND t1.binding_end_date >= spp.from_date
),
v_main AS
(
    SELECT
        vm.center,
        vm.id,
        vm.owner_center,
        vm.owner_id,
        vm.subscription_price,
        vm.binding_end_date,
        vm.billed_until_date,
        vm.spptype,
        SUM(vm.paid_amount) AS total_amount,
        min_spp,
        max_spp
    FROM initial_group vm
    WHERE
        vm.spptype IN ('INITIAL PERIOD', 'NORMAL')
    GROUP BY
        vm.center,
        vm.id,
        vm.owner_center,
        vm.owner_id,
        vm.subscription_price,
        vm.binding_end_date,
        vm.billed_until_date,
        vm.spptype,
        vm.min_spp,
        vm.max_spp
),
split_spptype AS
(
    SELECT
        ig.center,
        ig.id,
        ig.owner_center,
        ig.owner_id,
        ig.subscription_price,
        ig.binding_end_date,
        ig.billed_until_date,
        (CASE
            WHEN spptype = 'INITIAL PERIOD' THEN ig.total_amount 
            ELSE 0
        END) AS inital_amount,
        (CASE
            WHEN spptype = 'NORMAL' THEN ig.total_amount 
            ELSE 0
        END) AS normal_amount,
        min_spp,
        max_spp
    FROM v_main ig
),
v_pivot AS
(
    SELECT
        sp.center,
        sp.id,
        sp.owner_center,
        sp.owner_id,
        sp.subscription_price,
        sp.binding_end_date,
        sp.billed_until_date,
        SUM(sp.inital_amount) AS initial_total_amount,
        SUM(sp.normal_amount) AS normal_total_amount,
        sp.min_spp,
        sp.max_spp 
    FROM split_spptype sp
    GROUP BY
        sp.center,
        sp.id,
        sp.owner_center,
        sp.owner_id,
        sp.subscription_price,
        sp.binding_end_date,
        sp.billed_until_date,
        sp.min_spp,
        sp.max_spp
)
SELECT
    t2.owner_center || 'p' || t2.owner_id AS person_id,
    t2.center || 'ss' || t2.id AS subscription_id,
    t2.subscription_price,
    t2.binding_end_date,
    t2.min_invoiced_period AS invoiced_period_from,
    t2.max_invoiced_period AS invoiced_period_to,
    t2.fully_invoiced_already,
    t2.total_months_to_invoice,
    t2.binding_not_end_month,
    t2.future_freeze,
    t2.initial_period_amount,
    t2.normal_period_amount,
    COALESCE(sp.price, 0) * t2.total_months_to_invoice AS proyection_amount,
    COALESCE(t2.initial_period_amount, 0) 
    + COALESCE(t2.normal_period_amount, 0) 
    + COALESCE((COALESCE(sp.price, 0) * total_months_to_invoice), 0) 
    + COALESCE(ss.price_new, 0) AS total_amount,
    ss.price_new AS joining_amount
FROM
(
    SELECT
        t1.*,
        (CASE
            WHEN billed_until_date >= binding_end_date THEN 'YES'
            WHEN binding_end_date <= max_invoiced_period THEN 'YES' 
            WHEN binding_end_date > max_invoiced_period THEN 'NO'
        END) AS fully_invoiced_already,
        (CASE
            WHEN binding_end_date <= max_invoiced_period THEN 'OK'
            WHEN binding_end_date > max_invoiced_period 
                AND binding_end_date != DATE_TRUNC('month', binding_end_date + interval '1 months') - interval ' 1 days' THEN 'WATCHOUT'
            ELSE 'OK'
        END) AS binding_not_end_month,
        (CASE
            WHEN billed_until_date >= binding_end_date THEN 0
            WHEN binding_end_date <= max_invoiced_period THEN 0
            WHEN total_days_to_invoice > 0 THEN total_days_to_invoice / 28
            ELSE 0
        END) AS total_months_to_invoice,
        EXISTS (
            SELECT
                1
            FROM fw.subscription_freeze_period sfp
            WHERE 
                sfp.subscription_center = t1.center
                AND sfp.subscription_id = t1.id
                AND sfp.cancel_time IS NULL
                AND t1.binding_end_date > t1.max_invoiced_period
                AND sfp.start_date <= t1.binding_end_date
                AND sfp.end_date >= t1.max_invoiced_period 
        ) AS future_freeze
    FROM
    (
        SELECT
            gbs.center,
            gbs.id,
            gbs.owner_center,
            gbs.owner_id,
            gbs.subscription_price,
            gbs.initial_total_amount AS initial_period_amount,
            gbs.normal_total_amount AS normal_period_amount,
            gbs.min_spp AS min_invoiced_period,
            gbs.max_spp AS max_invoiced_period,
            gbs.binding_end_date,
            gbs.billed_until_date,
            gbs.binding_end_date - max_spp AS total_days_to_invoice
        FROM v_pivot gbs
    ) t1
) t2
LEFT JOIN fw.subscription_price sp
    ON sp.subscription_center = t2.center AND sp.subscription_id = t2.id AND t2.fully_invoiced_already = 'NO' AND sp.from_date < t2.binding_end_date AND (sp.to_date IS NULL OR sp.to_date > t2.max_invoiced_period)
LEFT JOIN fw.subscription_sales ss
    ON ss.subscription_center = t2.center AND ss.subscription_id = t2.id;
