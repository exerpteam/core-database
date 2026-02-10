-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/servicedesk/customer/portal/9/EC-4752

approved 7/29/22
WITH params AS MATERIALIZED
(
        SELECT
                to_date(:PeriodFrom,'YYYY-MM-DD') AS period_from,
                to_date(:PeriodTo,'YYYY-MM-DD') AS period_to,
                c.name AS center_name,
                c.id AS center_id,
                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') - interval '1 days' AS DATE) AS end_of_month,
                (CASE
                         WHEN EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) = 1 THEN
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 months') AS DATE) 
                         ELSE
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS DATE)
                END) AS last_billing_period_start,
                (CASE
                         WHEN EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) = 1 THEN
                                CAST(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days' AS DATE)
                         ELSE
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') - interval '1 days' AS DATE)
                END) AS last_billing_period_end
        FROM centers c
        WHERE
                c.id IN (:Scope)
),
list_subs AS
(
        SELECT
                t1.*,
                (CASE
                        WHEN t1.nextDeductionDate IS NULL THEN NULL
                        ELSE t1.nextDeductionDate + interval '1 months' -  interval '1 days'
                 END) AS nextDeductionDateEnds
        FROM
        (
                SELECT
                        (CASE
                                WHEN sub.billed_until_date = sub.end_date THEN NULL
                                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) = EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                                        CAST(DATE_TRUNC('month',sub.billed_until_date) AS DATE)
                                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) != EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                                        CAST(sub.billed_until_date + interval '1 day' AS DATE)
                                WHEN sub.start_date <= par.end_of_month THEN CAST(par.end_of_month + interval '1 day' AS DATE)
                                WHEN sub.start_date > par.end_of_month THEN CAST(DATE_TRUNC('month',sub.start_date) AS DATE)
                                ELSE NULL
                        END) AS nextDeductionDate,
                        pr.name AS product_name,
                        sub.start_date,
                        sub.state,
                        sub.sub_state,
                        sub.end_date AS sub_end_date,
                        sub.center,
                        sub.id,
                        sfp.type,
                        sfp.start_date AS freeze_start,
                        sfp.end_date AS freeze_end,
                        sub.owner_center,
                        sub.owner_id,
                        par.center_name,
                        sub.subscription_price,
                        fpr.price AS freeze_product_price
                FROM subscriptions sub
                JOIN params par
                        ON par.center_id = sub.center
                JOIN chelseapiers.subscription_freeze_period sfp
                        ON sub.center = sfp.subscription_center
                        AND sub.id = sfp.subscription_id
                        AND sfp.state = 'ACTIVE'
                        AND sfp.start_date <= par.period_to
                        AND sfp.end_date >= par.period_from
                JOIN subscriptiontypes st
                        ON st.center = sub.subscriptiontype_center
                        AND st.id = sub.subscriptiontype_id
                JOIN chelseapiers.products pr
                        ON pr.center = st.center
                        AND pr.id = st.id 
                LEFT JOIN chelseapiers.products fpr
                        ON fpr.center = st.freezeperiodproduct_center
                        AND fpr.id = st.freezeperiodproduct_id
        ) t1
),
previous_billing AS
(
        SELECT
                ls.center || 'ss' || ls.id,
                ls.center,
                ls.id,
                SUM(il.net_amount) as previous_amount            
        FROM list_subs ls
        JOIN params par ON par.center_id = ls.center
        JOIN chelseapiers.subscriptionperiodparts spp ON ls.center = spp.center AND ls.id = spp.id
        JOIN chelseapiers.spp_invoicelines_link sppl ON spp.center = sppl.period_center AND spp.id = sppl.period_id AND spp.subid = sppl.period_subid
        JOIN chelseapiers.invoice_lines_mt il ON il.center = sppl.invoiceline_center AND il.id = sppl.invoiceline_id AND il.subid = sppl.invoiceline_subid
        WHERE
                spp.cancellation_time = 0
                AND spp.from_date >= par.last_billing_period_start
                AND spp.to_date <= par.last_billing_period_end
        GROUP BY
                ls.center,
                ls.id
),
sub_price AS
(
        SELECT
                DISTINCT
                ls.center,
                ls.id,
                sp.price          
        FROM list_subs ls
        JOIN params par ON par.center_id = ls.center
        JOIN subscription_price sp
                ON sp.subscription_center = ls.center
                AND sp.subscription_id = ls.id
                AND sp.from_date <= ls.nextDeductionDate
                AND 
                (
                        sp.to_date IS NULL
                        OR  
                        sp.to_date >= ls.nextDeductionDate
                )
                AND sp.cancelled = false      
),
free_freeze_period AS
(
        SELECT
                ls.center,
                ls.id,
                MIN(srp.id) AS srp_id,
                MIN(sfp.id) AS sfp_id,
                MIN(sfp.type) AS sfp_type
        FROM list_subs ls
        LEFT JOIN chelseapiers.subscription_freeze_period sfp
                ON sfp.subscription_center = ls.center
                AND sfp.subscription_id = ls.id
                AND sfp.cancel_time IS NULL
                AND sfp.start_date <=ls.nextDeductionDateEnds
                AND sfp.end_date >= ls.nextDeductionDate
                AND sfp.state IN ('ACTIVE')
        LEFT JOIN chelseapiers.subscription_reduced_period srp
                ON srp.subscription_center = ls.center
                AND srp.subscription_id = ls.id
                AND srp.cancel_time IS NULL
                AND srp.start_date <=ls.nextDeductionDateEnds
                AND srp.end_date >= ls.nextDeductionDate
                AND srp.type NOT IN ('FREEZE')
                AND srp.state IN ('ACTIVE')        
        GROUP BY
                ls.center,
                ls.id
)
SELECT
        ls.center_name AS "Center",
        p.center || 'p' || p.id AS "Person ID", 
        p.external_id AS "External ID",
        p.firstname AS "First Name",
        p.lastname AS "Last Name",
        --TO_CHAR(p.first_active_start_date,'mm/dd/yyyy') AS "Member Since Date",
        TO_CHAR(ls.start_date,'mm/dd/yyyy') AS "Member Since Date",
        TO_CHAR(ls.sub_end_date,'mm/dd/yyyy') AS "Subscription End Date",
        CASE ls.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State",
        CASE ls.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS "Subscription Sub State",
        (CASE p.PERSONTYPE
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                WHEN 9 THEN 'CHILD'
                WHEN 10 THEN 'EXTERNAL_STAFF'
                ELSE 'UNDEFINED'
        END) AS "Person Type",                                                
        ls.center || 'ss' || ls.id AS "Subscription ID",
        ls.product_name AS "Subscription Name",
        ls.type AS "Type of Freeze",
        TO_CHAR(ls.freeze_start,'mm/dd/yyyy') AS "Freeze Start",
        TO_CHAR(ls.freeze_end,'mm/dd/yyyy') AS "Freeze End",
        ls.subscription_price AS "Key Item Price",
        pb.previous_amount AS "Previous Billing",
        (CASE
                WHEN ffp.srp_id IS NOT NULL THEN
                        0.00
                WHEN ffp.sfp_id IS NOT NULL AND ffp.sfp_type = 'UNRESTRICTED' THEN 
                        0.00
                WHEN ffp.sfp_id IS NOT NULL THEN
                        ls.freeze_product_price
                ELSE 
                        sp.price
        END) AS "Price (Next deduction)",
        TO_CHAR(ls.nextDeductionDate,'mm/dd/yyyy') AS "Next Deduction Date",
        email.txtvalue AS "Email"
FROM list_subs ls
JOIN persons p
        ON ls.owner_center = p.center
        AND ls.owner_id = p.id
LEFT JOIN chelseapiers.person_ext_attrs email
        ON email.personcenter = p.center AND email.personid = p.id AND email.name = '_eClub_Email'
LEFT JOIN previous_billing pb
        ON pb.center = ls.center
        AND pb.id = ls.id
LEFT JOIN free_freeze_period ffp
        ON ffp.center = ls.center
        AND ffp.id = ls.id
LEFT JOIN sub_price sp
        ON ls.center = sp.center
        AND ls.id = sp.id
