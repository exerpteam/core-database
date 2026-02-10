-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/servicedesk/customer/portal/9/EC-5068

approved 8/9/2022
WITH
    params AS MATERIALIZED
    (
        SELECT
                datetoLongC(getCenterTime(c.id),c.id)     AS today,
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS today_date,
                CAST(DATE_TRUNC('MONTH',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')+ interval '1 months') - interval '1 days' AS DATE) AS end_of_month,
                CAST(DATE_TRUNC('MONTH',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS DATE) AS last_billing_period_start,
                CAST(DATE_TRUNC('MONTH',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') - interval '1 days' AS DATE) AS last_billing_period_end,
            c.id AS center_id
        FROM
            chelseapiers.centers c
	    WHERE
			c.id IN (:Scope)
    ),
list_sub AS
(
        SELECT
                (CASE
                WHEN sub.billed_until_date = sub.end_date THEN
                        NULL
                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) = EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                         CAST(DATE_TRUNC('month',sub.billed_until_date) AS DATE)
                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) != EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                        CAST(sub.billed_until_date + interval '1 day' AS DATE)
                WHEN sub.start_date <= par.end_of_month THEN
                        CAST(par.end_of_month + interval '1 day' AS DATE)
                WHEN sub.start_date > par.end_of_month THEN
                        CAST(DATE_TRUNC('month',sub.start_date) AS DATE)
                ELSE 
                        NULL
                END) AS nextDeductionDate,
                pd.name as sub_name,
                pg.name as product_group_name,
                sub.center,
                sub.id,
                sub.billed_until_date,
                sub.end_date,
                sub.start_date,
                fpr.price AS freeze_product_price,
                sub.owner_center,
                sub.owner_id,
                sub.state,
                sub.binding_end_date,
                sub.binding_price,
                sub.subscription_price,
                st.st_type,
                inv.total_amount,
                par.last_billing_period_start,
                par.last_billing_period_end,
                par.today_date
        FROM subscriptions sub
        JOIN params par ON sub.center = par.center_id
        JOIN products pd
                ON pd.center = sub.subscriptiontype_center
                AND pd.id = sub.subscriptiontype_id
        JOIN subscriptiontypes st
                ON st.center = pd.center
                AND st.id = pd.id
        JOIN chelseapiers.product_group pg 
                ON pd.primary_product_group_id = pg.id
        LEFT JOIN chelseapiers.products fpr
                ON fpr.center = st.freezeperiodproduct_center
                AND fpr.id = st.freezeperiodproduct_id
        LEFT JOIN chelseapiers.subscriptionperiodparts spp
                ON spp.center = sub.center
                AND spp.id = sub.id
                AND st.st_type = 0   
                AND spp.cancellation_time = 0          
        LEFT JOIN chelseapiers.spp_invoicelines_link sppil
                ON sppil.period_center = spp.center
                AND sppil.period_id = spp.id
                AND sppil.period_subid = spp.subid
        LEFT JOIN chelseapiers.invoice_lines_mt inv
                ON inv.center = sppil.invoiceline_center
                AND inv.id = sppil.invoiceline_id
                AND inv.subid = sppil.invoiceline_subid
               
                
        WHERE
                sub.state IN (2,4,8)
               
),
previous_billing AS
(
        SELECT
                s.center || 'ss' || s.id,
                s.center,
                s.id,
                SUM(il.net_amount) as previous_amount            
        FROM list_sub s
        JOIN chelseapiers.subscriptionperiodparts spp ON s.center = spp.center AND s.id = spp.id
        JOIN chelseapiers.spp_invoicelines_link sppl ON spp.center = sppl.period_center AND spp.id = sppl.period_id AND spp.subid = sppl.period_subid
        JOIN chelseapiers.invoice_lines_mt il ON il.center = sppl.invoiceline_center AND il.id = sppl.invoiceline_id AND il.subid = sppl.invoiceline_subid
        WHERE
                spp.cancellation_time = 0
                AND spp.from_date >= s.last_billing_period_start
                AND spp.to_date <= s.last_billing_period_end
        GROUP BY
                s.center,
                s.id
),
subscription_price AS
(
        SELECT
                t1.center,
                t1.id,
                (CASE
                        WHEN srp.id IS NOT NULL THEN
                                0.00
                        WHEN sfp.id IS NOT NULL AND sfp.type = 'UNRESTRICTED' THEN 
                                0.00
                        WHEN sfp.id IS NOT NULL THEN
                                t1.freeze_product_price
                        ELSE 
                                t1.price
                END) AS NextDeduction
        FROM
        (
                SELECT
                        s.center,
                        s.id,
                        s.nextDeductionDate,
                        sp.price,
                        s.freeze_product_price       
                FROM list_sub s
                JOIN params par ON par.center_id = s.center
                JOIN subscription_price sp
                        ON sp.subscription_center = s.center
                        AND sp.subscription_id = s.id
                        AND sp.from_date <= s.nextDeductionDate
                        AND 
                        (
                                sp.to_date IS NULL
                                OR  
                                sp.to_date >= s.nextDeductionDate
                        )
                        AND sp.cancelled = false   
        ) t1
        LEFT JOIN chelseapiers.subscription_freeze_period sfp
                ON sfp.subscription_center = t1.center
                AND sfp.subscription_id = t1.id
                AND sfp.cancel_time IS NULL
                AND sfp.start_date <= t1.nextDeductionDate
                AND sfp.end_date > t1.nextDeductionDate
                AND sfp.state IN ('ACTIVE')
        LEFT JOIN chelseapiers.subscription_reduced_period srp
                ON srp.subscription_center = t1.center
                AND srp.subscription_id = t1.id
                AND srp.cancel_time IS NULL
                AND srp.start_date <=t1.nextDeductionDate
                AND srp.end_date > t1.nextDeductionDate
                AND srp.type NOT IN ('FREEZE')
                AND srp.state IN ('ACTIVE')
)     
SELECT 
        DISTINCT
        p.center || 'p' || p.id  AS "Member id",
        s.center || 'ss' || s.id AS "Subscription id",
        p.fullname               AS "Member name",
        (CASE p.persontype 
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 3 THEN 'Friend'
                WHEN 4 THEN 'Corporate'
                WHEN 5 THEN 'One Man Corporate'
                WHEN 6 THEN 'Family'
                WHEN 7 THEN 'Senior'
                WHEN 8 THEN 'Guest'
                WHEN 9 THEN 'Child'
                WHEN 10 THEN 'External Staff'
                ELSE 'UNKNOWN'
        END) AS "Person Type",
        s.sub_name                  AS "Type of subscription",
        s.product_group_name AS "Product Group",
        (CASE s.STATE
                WHEN 2
                        THEN 'ACTIVE'
                WHEN 4
                        THEN 'FROZEN'
                WHEN 8
                        THEN 'CREATED'
                ELSE 
                        'Undefined'
        END) AS "Subscription state",
        'YES'        AS "Primary member",
        NULL         AS "Primary member id",
        NULL         AS "Primary member name",
        to_char(s.start_date,'MM-DD-YYYY') AS "Start date",
        to_char(s.end_date,'MM-DD-YYYY')   AS "Termination date",
        (
        CASE
                WHEN s.st_type = 0
                THEN s.total_amount
                WHEN s.binding_end_date IS NOT NULL AND s.binding_end_date >= s.today_date
                        THEN s.binding_price
                ELSE 
                        s.subscription_price
        END) AS "Key item price",
        NULL AS Addon_Name,
        pb.previous_amount AS "Previous deduction amount",
        to_char(s.nextDeductionDate,'MM-DD-YYYY') AS "Next deduction date",
        sp.NextDeduction AS "Next deduction amount"       
FROM list_sub s
JOIN chelseapiers.persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
LEFT JOIN previous_billing pb
        ON pb.center = s.center
        AND pb.id = s.id
LEFT JOIN subscription_price sp
        ON sp.center = s.center
        AND sp.id = s.id
UNION ALL
SELECT
    t1.*
FROM
    (
        WITH
            params AS
            (
                SELECT
                    datetoLongC(getCenterTime(c.id),c.id) AS today,
                    c.id
                FROM
                    chelseapiers.centers c
            )
        SELECT
            p.center || 'p' || p.id  AS "Member id",
            s.center || 'ss' || s.id AS "Subscription id",
            p.fullname               AS "Member name",
             (CASE p.persontype 
                WHEN 0 THEN 'Private'
                WHEN 1 THEN 'Student'
                WHEN 2 THEN 'Staff'
                WHEN 3 THEN 'Friend'
                WHEN 4 THEN 'Corporate'
                WHEN 5 THEN 'One Man Corporate'
                WHEN 6 THEN 'Family'
                WHEN 7 THEN 'Senior'
                WHEN 8 THEN 'Guest'
                WHEN 9 THEN 'Child'
                WHEN 10 THEN 'External Staff'
                ELSE 'UNKNOWN'
        END) AS "Person Type",
            pr.name                  AS "Type of subscription",
            pg.name AS "Product Group",
            CASE s.STATE
                WHEN 2
                THEN 'ACTIVE'
                WHEN 4
                THEN 'FROZEN'
                WHEN 8
                THEN 'CREATED'
                ELSE 'Undefined'
            END                                 AS "Subscription state",
            'NO'                                AS "Primary member",
            s.owner_center || 'p' || s.owner_id AS "Primary member id",
            main_p.fullname                     AS "Primary member name",
            to_char(sa.start_date,'MM-DD-YYYY')                        AS "Start date",
            to_char(sa.end_date,'MM-DD-YYYY')                          AS "Termination date",
            (CASE WHEN sa.use_individual_price = true
                THEN sa.individual_price_per_unit 
                ELSE mpr.cached_productprice
            END) AS "Key item price",
            mpr.cached_productname              AS "Addon name",
            CAST(NULL AS NUMERIC),
            NULL,
            CAST(NULL AS NUMERIC)
        FROM
            chelseapiers.secondary_memberships sm
        JOIN
            params par
        ON
            par.id = sm.secondary_member_person_center
        JOIN
            chelseapiers.persons p
        ON
            p.center = sm.secondary_member_person_center
        AND p.id = sm.secondary_member_person_id
        JOIN
            chelseapiers.subscription_addon sa
        ON
            sa.id = sm.subscription_add_on_id
        JOIN
            chelseapiers.subscriptions s
        ON
            sa.subscription_center = s.center
        AND sa.subscription_id = s.id
        JOIN
            chelseapiers.persons main_p
        ON
            s.owner_center = main_p.center
        AND s.owner_id = main_p.id
        JOIN
            chelseapiers.subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        JOIN
            chelseapiers.products pr
        ON
            st.center = pr.center
        AND st.id = pr.id
        JOIN
            chelseapiers.masterproductregister mpr
        ON
            mpr.id = sa.addon_product_id
        JOIN 
            chelseapiers.product_group pg
        ON
            pg.id = mpr.primary_product_group_id
        WHERE
            sm.stop_time IS NULL
        OR  sm.stop_time > par.today 
) t1