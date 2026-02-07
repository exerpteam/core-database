----- ASSUMPTIONS FOR THIS SCRIPT ------
----- 1. We do NOT have other payer relations
----- 2. We are NOT looking at possible privileges that the member might get to get a discount on her next deduction
----- 3. We are NOT looking at corporate members
----- 4. Addons without IndividualPrice are not included

----- IMPROVEMENTS ------
----- 1. We still need to include ADDONS (COMPLETED)
----- 2. We still need to check for Price Updates (COMPLETED)
----- 3. We need to check if the freezes are free or not, if not we need to see how we can get the freeze price (COMPLETED)
----- 4. We need to flag if the next period is within binding period or not to apply the right price (Not needed)
----- 5. Add Installment Plans (COMPLETED)
----- 6. Add Overdue Debt (COMPLETED)

-----Payment Cycle options
-----11 - Big billing
-----4 - Small billing

--------------  DEFINE THE PERIOD YOU ARE LOOKING FOR AND THE PAYMENT CYCLE --------------
WITH PARAMS AS 
(
        SELECT
                TO_DATE(:StartOfRenewDate,'YYYY-MM-DD') AS FROM_DATE,
                TO_DATE(:EndOfRenewDate,'YYYY-MM-DD') AS TO_DATE,
                CAST(:PaymentCycle AS INT) AS PAYMENT_CYCLE
),
-------------- ELIGIBLE_SUB -------------- 
ELIGIBLE_SUB AS
(
        SELECT
                s.center,
                s.id,
                s.owner_center,
                s.owner_id,
                s.start_date,
                s.binding_end_date,
                s.billed_until_date,
                s.end_date,
                s.individual_price,
                s.subscription_price,
                s.binding_price,
                par.FROM_DATE,
                par.TO_DATE,
                st.st_type,
                s.subscriptiontype_center,
                s.subscriptiontype_id,
                GREATEST(s.start_date,par.FROM_DATE) AS period_from,
                LEAST(COALESCE(s.end_date,par.TO_DATE),par.TO_DATE) AS period_to
        FROM
                fernwood.subscriptions s
        CROSS JOIN PARAMS par
        JOIN
                fernwood.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id AND st.st_type != 0
        JOIN
                fernwood.account_receivables ar ON s.owner_center = ar.customercenter AND s.owner_id = ar.customerid AND ar.ar_type = 4
        JOIN
                fernwood.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
        JOIN
                fernwood.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid AND pag.individual_deduction_day = par.PAYMENT_CYCLE
        WHERE
                s.state IN (2,4,8)
                AND s.start_date <= par.TO_DATE
                AND
                (
                        s.end_date IS NULL
                        OR
                        s.end_date >= par.FROM_DATE
                )
                AND
                (
                        s.billed_until_date IS NULL
                        OR 
                        s.billed_until_date < par.TO_DATE
                )
                AND
                (
                        s.end_date IS NULL
                        OR
                        s.billed_until_date IS NULL
                        OR
                        s.end_date != s.billed_until_date
                )
),
-------------- FREEZE_PERIOD -------------- 
FREEZE_PERIOD_SUB AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                SUM(num_freeze_days) total_freeze_days,
                t2.FreezePrice
        FROM
        (
                SELECT
                        t1.*,
                        t1.freeze_end-t1.freeze_start+1 AS num_freeze_days,
                        ROUND(t1.Freeze_Price/14,2) AS FreezePrice 
                        
                FROM
                (
                        SELECT
                                sfp.subscription_center,
                                sfp.subscription_id,
                                sfp.start_date,
                                sfp.end_date,
                                GREATEST(sfp.start_date,es.FROM_DATE) AS freeze_start,
                                LEAST(sfp.end_date,es.TO_DATE) AS freeze_end,
                                prf.price AS Freeze_Price
                        FROM
                                ELIGIBLE_SUB es
                        JOIN
                                fernwood.subscription_freeze_period sfp ON es.center = sfp.subscription_center AND es.id = sfp.subscription_id
                        JOIN    fernwood.subscriptiontypes st ON st.center = es.subscriptiontype_center AND st.id = es.subscriptiontype_id        
                        JOIN    fernwood.products prf ON st.freezeperiodproduct_center = prf.center AND st.freezeperiodproduct_id = prf.id                                
                        WHERE   
                                sfp.cancel_time IS NULL
                                AND sfp.start_date <= es.TO_DATE
                                AND sfp.end_date >= es.FROM_DATE
                ) t1
        ) t2
        GROUP BY
                t2.subscription_center,
                t2.subscription_id,
                t2.FreezePrice
),
-------------- FREE_PERIOD -------------- 
FREE_PERIOD_SUB AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                SUM(num_free_days) AS total_free_days
        FROM
        (
                SELECT
                        t1.*,
                        t1.free_end-t1.free_start+1 AS num_free_days
                FROM
                (
                        SELECT
                                srp.subscription_center,
                                srp.subscription_id,
                                srp.start_date,
                                srp.end_date,
                                srp.freeze_period,
                                srp.type,
                                GREATEST(srp.start_date,es.FROM_DATE) AS free_start,
                                LEAST(srp.end_date,es.TO_DATE) AS free_end
                        FROM
                                ELIGIBLE_SUB es
                        JOIN
                                fernwood.subscription_reduced_period srp ON es.center = srp.subscription_center AND es.id = srp.subscription_id
                        WHERE   
                                srp.cancel_time IS NULL
                                AND srp.start_date <= es.TO_DATE
                                AND srp.end_date >= es.FROM_DATE
                                AND srp.freeze_period IS NULL
                                AND srp.type != 'FREEZE'
                ) t1
        ) t2
        GROUP BY
                t2.subscription_center,
                t2.subscription_id
),
SUBSCRIPTION_ADDONS AS
(
        SELECT
                t1.*,
                t1.addon_period_to-t1.addon_period_from+1 AS theorical_days_to_invoice_addon
        FROM
        (
                SELECT
                        sa.subscription_center,
                        sa.subscription_id,
                        sa.id,
                        sa.individual_price_per_unit,
                        GREATEST(es.period_from, sa.start_date) AS addon_period_from,
                        LEAST(COALESCE(sa.end_date,es.period_to),es.period_to) AS addon_period_to
                FROM ELIGIBLE_SUB es
                JOIN fernwood.subscription_addon sa ON sa.subscription_center = es.center AND sa.subscription_id = es.id
                WHERE
                        sa.cancelled = false
                        AND sa.start_date <= es.TO_DATE
                        AND
                        (
                                sa.end_date IS NULL
                                OR
                                sa.end_date >= es.FROM_DATE
                        )
                        AND sa.use_individual_price = true 
                        AND SA.individual_price_per_unit > 0
                ) t1
),
FREEZE_PERIOD_ADDON AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                t2.id,
                SUM(num_freeze_days_addon) total_freeze_days_addon
        FROM
        (
                SELECT
                        t1.*,
                        t1.freeze_end_addon-t1.freeze_start_addon+1 AS num_freeze_days_addon
                FROM
                (
                        SELECT
                                sa.id,
                                sfp.subscription_center,
                                sfp.subscription_id,
                                sfp.start_date,
                                sfp.end_date,
                                GREATEST(sfp.start_date,sa.addon_period_from) AS freeze_start_addon,
                                LEAST(sfp.end_date,sa.addon_period_to) AS freeze_end_addon
                        FROM
                                SUBSCRIPTION_ADDONS sa
                        JOIN
                                fernwood.subscription_freeze_period sfp ON sa.subscription_center = sfp.subscription_center AND sa.subscription_id = sfp.subscription_id
                        WHERE   
                                sfp.cancel_time IS NULL
                                AND sfp.start_date <= sa.addon_period_to
                                AND sfp.end_date >= sa.addon_period_from
                ) t1
        ) t2
        GROUP BY
                t2.subscription_center,
                t2.subscription_id,
                t2.id
),
FREE_PERIOD_ADDON AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                t2.id,
                SUM(num_free_days_addon) AS total_free_days_addon
        FROM
        (
                SELECT
                        t1.*,
                        t1.free_end_addon-t1.free_start_addon+1 AS num_free_days_addon
                FROM
                (
                        SELECT
                                sa.id,
                                srp.subscription_center,
                                srp.subscription_id,
                                srp.start_date,
                                srp.end_date,
                                srp.freeze_period,
                                srp.type,
                                GREATEST(srp.start_date,sa.addon_period_from) AS free_start_addon,
                                LEAST(srp.end_date,sa.addon_period_from) AS free_end_addon
                        FROM
                                SUBSCRIPTION_ADDONS sa
                        JOIN
                                fernwood.subscription_reduced_period srp ON sa.subscription_center = srp.subscription_center AND sa.subscription_id = srp.subscription_id
                        WHERE   
                                srp.cancel_time IS NULL
                                AND srp.start_date <= sa.addon_period_to
                                AND srp.end_date >= sa.addon_period_from
                                AND srp.freeze_period IS NULL
                                AND srp.type != 'FREEZE'
                ) t1
        ) t2
        GROUP BY
                t2.subscription_center,
                t2.subscription_id,
                t2.id
),
ADDONS_TOTAL AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                SUM(t2.amount_to_invoice_addon) AS total_amount_addons
        FROM
        (
                SELECT
                        t1.*,
                        (CASE
                                WHEN t1.days_to_invoice_addon = 14 THEN t1.individual_price_per_unit
                                ELSE round(t1.daily_price_addon * t1.days_to_invoice_addon,2)
                        END) AS amount_to_invoice_addon
                FROM
                (
                        SELECT
                                sa.*,
                                round(sa.individual_price_per_unit/14,4) AS daily_price_addon,
                                sa.theorical_days_to_invoice_addon - COALESCE(fzpa.total_freeze_days_addon,0) - COALESCE(fpa.total_free_days_addon,0) AS days_to_invoice_addon
                        FROM
                                SUBSCRIPTION_ADDONS sa
                        LEFT JOIN FREEZE_PERIOD_ADDON fzpa ON sa.id = fzpa.id
                        LEFT JOIN FREE_PERIOD_ADDON fpa ON sa.id = fpa.id
                ) t1
                WHERE
                        t1.days_to_invoice_addon > 0
        ) t2
        GROUP BY 
                t2.subscription_center,
                t2.subscription_id
),
-------------- Subscription Price Change -------------- 
SUB_PRICE AS
(
        SELECT
                t2.subscription_center,
                t2.subscription_id,
                t2.daily_price_update,
                SUM(num_price_days) total_price_days
        FROM
        (
                SELECT
                        t1.*,
                        t1.Price_end-t1.Price_start+1 AS num_price_days,
                        ROUND(t1.price/14,2) AS daily_price_update
                FROM
                (
                        SELECT
                                sp.subscription_center,
                                sp.subscription_id,
                                sp.from_date,
                                sp.to_date,
                                sp.price,
                                GREATEST(sp.from_date,par.FROM_DATE) AS Price_start,
                                LEAST(sp.to_date,par.TO_DATE) AS Price_end
                        FROM
                                ELIGIBLE_SUB es
                        CROSS JOIN PARAMS par                                
                        JOIN
                                fernwood.subscription_price sp ON sp.subscription_center = es.center AND sp.subscription_id = es.id
                        WHERE
                                sp.cancelled IS FALSE
                                AND sp.from_date <= par.TO_DATE
                                AND 
                                (
                                        sp.to_date IS NULL 
                                        OR 
                                        sp.to_date >= par.FROM_DATE
                                )
                                AND es.subscription_price != sp.price                                      

                ) t1
        ) t2
        GROUP BY
                t2.subscription_center,
                t2.subscription_id,
                t2.daily_price_update
),
-------------- DRILL_DOWN_LIST -------------- 
DRILL_DOWN_LIST AS
(
        SELECT
                t1.*,
                t1.period_to-t1.period_from+1 AS theorical_days_to_invoice
        FROM
        (
                SELECT
                        es.*,
                        freeze_p.total_freeze_days,
                        free_p.total_free_days,
                        freeze_p.FreezePrice,
                        addtot.total_amount_addons,
                        SP.total_price_days,
                        SP.daily_price_update
                FROM
                        ELIGIBLE_SUB es
                LEFT JOIN FREEZE_PERIOD_SUB freeze_p ON es.center = freeze_p.subscription_center AND es.id = freeze_p.subscription_id
                LEFT JOIN FREE_PERIOD_SUB free_p ON es.center = free_p.subscription_center AND es.id = free_p.subscription_id
                LEFT JOIN ADDONS_TOTAL addtot ON addtot.subscription_center = es.center AND addtot.subscription_id = es.id
                LEFT JOIN SUB_PRICE SP ON SP.subscription_center = es.center AND SP.subscription_id = es.id
        ) t1
), 
-------------- Members with values for Renewal/Installment/Manual Invoice/Overdue amount -------------- 
FIRST_LIST AS
(
        SELECT
                t."Person ID",
                t."Member Name",
                t."Person Status",
                t."Renewal amount", 
                t."Installment plan amount",
                t."Manual Invoices/Credits amount",
                t."Overdue amount",       
                t."Deduction Date",
                CASE
                        WHEN (t."Renewal amount" + t."Installment plan amount" + t."Manual Invoices/Credits amount" + t."Overdue amount") < 0 THEN (t."Renewal amount" + t."Installment plan amount" + t."Manual Invoices/Credits amount" + t."Overdue amount")
                        ELSE 0
                END AS "Total Debit BEFORE Renewal",
                t."Installment plan amount" + t.balance AS "Total Debit AFTER Renewal",
                CASE 
                        WHEN t.state = 1 THEN 'Created' 
                        WHEN t.state = 2 THEN 'Sent' 
                        WHEN t.state = 3 THEN 'Failed' 
                        WHEN t.state = 4 THEN 'OK' 
                        WHEN t.state = 5 THEN 'Ended = bank' 
                        WHEN t.state = 6 THEN 'Ended = clearing house' 
                        WHEN t.state = 7 THEN 'Ended = debtor' 
                        WHEN t.state = 8 THEN 'Cancelled = not sent' 
                        WHEN t.state = 9 THEN 'Cancelled = sent' 
                        WHEN t.state = 10 THEN 'Ended = creditor' 
                        WHEN t.state = 11 THEN 'No agreement' 
                        WHEN t.state = 12 THEN 'Cash payment (deprecated)' 
                        WHEN t.state = 13 THEN 'Agreement not needed (invoice payment)' 
                        WHEN t.state = 14 THEN 'Agreement information incomplete' 
                        WHEN t.state = 15 THEN 'Transfer' 
                        WHEN t.state = 16 THEN 'Agreement Recreated' 
                        WHEN t.state = 17 THEN 'Signature missing' 
                        ELSE 'UNDEFINED' 
                END AS "Payment Agreement State",
                CASE
                        WHEN t.clearinghouse = 1 THEN 'Bank Account'
                        WHEN t.clearinghouse = 2 THEN 'Credit Card'
                END AS "Clearing House"                        
        FROM
                (                
                SELECT
                        ms."Person ID",
                        p.fullname AS "Member Name",
                        bi_decode_field('PERSONS', 'STATUS', p.status) AS "Person Status",
                        -ms."Amount to be invoiced" AS "Renewal amount", 
                        -ms."Installment Plan Amount" AS "Installment plan amount",
                        -ms."Manual Invoices/Credits" AS "Manual Invoices/Credits amount",
                        -ms."Overdue/Outstanding Amount" AS "Overdue amount",       
                        ms."Deduction Date",
                        pag.state,
                        pag.clearinghouse,
                        ar.balance 
                FROM
                        (                
                        SELECT
                                t1."Person ID",
                                SUM(t1."Amount to be invoiced") AS "Amount to be invoiced",
                                SUM(t1."Installment Plan Amount") AS "Installment Plan Amount",
                                SUM(t1."Overdue/Outstanding Amount") AS "Overdue/Outstanding Amount",
                                SUM(t1."Manual Invoices/Credits") AS "Manual Invoices/Credits",
                                t1."Deduction Date"
                        FROM
                                (
                                SELECT
                                        t2.PersonId AS "Person ID",
                                        SUM(t2.amount_to_invoice_sub) AS "Amount to be invoiced",
                                        0 AS "Installment Plan Amount",
                                        0 AS "Overdue/Outstanding Amount",
                                        0 AS "Manual Invoices/Credits",
                                        par.FROM_DATE AS "Deduction Date"     
                                FROM        
                                        (
                                                SELECT DISTINCT
                                                        t1.owner_center || 'p' || t1.owner_id AS PersonId,
                                                        t1.*,
                                                        (CASE
                                                                WHEN t1.total_price_days IS NULL THEN (ROUND(COALESCE(t1.FreezePrice,t1.daily_price) * t1.days_to_invoice,2)) + COALESCE(t1.total_amount_addons,0)
                                                                ELSE (ROUND(((t1.days_to_invoice - t1.total_price_days) * COALESCE(t1.FreezePrice,t1.daily_price)) + (t1.total_price_days * COALESCE(t1.FreezePrice,t1.daily_price_update)),2)) + COALESCE(t1.total_amount_addons,0)                                                         
                                                        END) AS amount_to_invoice_sub
                                                FROM
                                                (
                                                        SELECT
                                                                ddl.center,
                                                                ddl.id,
                                                                ddl.owner_center,
                                                                ddl.owner_id,
                                                                ddl.start_date,
                                                                ddl.binding_end_date,
                                                                ddl.billed_until_date,
                                                                ddl.end_date,
                                                                ddl.subscription_price,
                                                                ddl.binding_price,
                                                                ddl.period_from,
                                                                ddl.period_to,
                                                                ddl.total_freeze_days,
                                                                ddl.total_free_days,
                                                                ddl.theorical_days_to_invoice,
                                                                round(ddl.subscription_price/14,4) AS daily_price,
                                                                ddl.theorical_days_to_invoice - COALESCE(ddl.total_free_days,0) AS days_to_invoice,
                                                                ddl.total_amount_addons AS amount_to_invoice_addons,
                                                                ddl.total_price_days,
                                                                ddl.daily_price_update,
                                                                ddl.FreezePrice,
                                                                ddl.total_amount_addons            
                                                        FROM
                                                                DRILL_DOWN_LIST ddl
                                                ) t1
                                                WHERE
                                                        t1.days_to_invoice > 0
                                        )t2                
                                CROSS JOIN PARAMS par
                                WHERE
                                        t2.owner_center in (:Scope)
                                GROUP BY
                                        t2.PersonId,
                                        par.FROM_DATE,
                                        t2.owner_center
                                UNION ALL
                                SELECT
                                        t1.customercenter||'p'||t1.customerid AS "Person ID",
                                        0 AS "Amount to be invoiced",
                                        sum(t1.Installament__Amount) AS "Installment Plan Amount",
                                        0 AS "Overdue/Outstanding Amount",
                                        0 AS "Manual Invoices/Credits",
                                        t1.due_date AS "Deduction Date"        
                                FROM   
                                
                                        (
                                                SELECT 
                                                       ar.customercenter,
                                                       ar.customerid,
                                                       art.due_date,
                                                       -art.amount AS Installament__Amount,
                                                       pag.individual_deduction_day                         
                                                FROM 
                                                        fernwood.account_receivables ar
                                                CROSS JOIN PARAMS par
                                                JOIN    fernwood.ar_trans art ON art.center = ar.center AND art.id = ar.id AND art.collected = 0 AND art.status = 'NEW'  
                                                JOIN    fernwood.installment_plans ip ON art.installment_plan_id = ip.id 
                                                JOIN    fernwood.payment_agreements pag ON pag.center = ip.collect_agreement_center AND pag.id = ip.collect_agreement_id AND pag.subid = ip.collect_agreement_subid AND pag.individual_deduction_day = par.PAYMENT_CYCLE                                                                                                                  
                                                WHERE 
                                                        art.due_date BETWEEN par.FROM_DATE AND par.TO_DATE
                                                        AND 
                                                        ar.ar_type = 6
                                                        AND 
                                                        ar.customercenter in (:Scope)
                                        )t1
                                        GROUP BY
                                                t1.customercenter,
                                                t1.customerid,
                                                t1.due_date
                                UNION ALL
                                SELECT
                                        t1.customercenter||'p'||t1.customerid AS "Person ID",
                                        0 AS "Amount to be invoiced",
                                        0 AS "Installment Plan Amount",
                                        t1."Overdue/Outstanding Amount" AS "Overdue/Outstanding Amount",
                                        0 AS "Manual Invoices/Credits",
                                        par.FROM_DATE AS "Deduction Date"        
                                FROM   
                                        (
                                                SELECT DISTINCT
                                                        ar.customercenter
                                                        ,ar.customerid
                                                        ,sum(-art.unsettled_amount) AS "Overdue/Outstanding Amount"
                                                        ,ar.balance
                                                        ,pag.individual_deduction_day
                                                FROM
                                                        fernwood.account_receivables ar
                                                CROSS JOIN PARAMS par                
                                                JOIN    fernwood.ar_trans art ON art.center = ar.center AND art.id = ar.id AND art.status != 'CLOSED'
                                                JOIN    fernwood.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
                                                JOIN    fernwood.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid AND pag.individual_deduction_day = par.PAYMENT_CYCLE
                                        
                                                WHERE
                                                        art.due_date < par.FROM_DATE
                                                        AND
                                                        ar.customercenter IN (:Scope)
                                                GROUP BY
                                                        ar.customercenter
                                                        ,ar.customerid 
                                                        ,ar.balance
                                                        ,pag.individual_deduction_day
                                        )t1
                                CROSS JOIN PARAMS par                
                                UNION ALL
                                SELECT
                                        t1.customercenter||'p'||t1.customerid AS "Person ID",
                                        0 AS "Amount to be invoiced",
                                        0 AS "Installment Plan Amount",
                                        0 AS "Overdue/Outstanding Amount",
                                        t1."Manual Invoices/Credits" AS "Manual Invoices/Credits",
                                        par.FROM_DATE AS "Deduction Date"        
                                FROM   
                                        (
                                                SELECT DISTINCT
                                                        ar.customercenter
                                                        ,ar.customerid
                                                        ,sum(-art.unsettled_amount) AS "Manual Invoices/Credits"
                                                        ,ar.balance
                                                        ,pag.individual_deduction_day
                                                FROM
                                                        fernwood.account_receivables ar
                                                CROSS JOIN PARAMS par                
                                                JOIN    fernwood.ar_trans art ON art.center = ar.center AND art.id = ar.id AND art.status != 'CLOSED'
                                                JOIN    fernwood.payment_accounts pac ON ar.center = pac.center AND ar.id = pac.id
                                                JOIN    fernwood.payment_agreements pag ON pac.active_agr_center = pag.center AND pac.active_agr_id = pag.id AND pac.active_agr_subid = pag.subid AND pag.individual_deduction_day = par.PAYMENT_CYCLE
                                        
                                                WHERE
                                                        (
                                                        art.due_date IS NULL
                                                        OR
                                                        art.due_date = par.FROM_DATE
                                                        )
                                                        AND
                                                        ar.customercenter IN (:Scope)
                                                        AND 
                                                        art.text NOT LIKE '%(Auto Renewal)'
                                                GROUP BY
                                                        ar.customercenter
                                                        ,ar.customerid 
                                                        ,ar.balance
                                                        ,pag.individual_deduction_day
                                        )t1                 
                                CROSS JOIN PARAMS par 
                                )t1    
                        GROUP BY
                                t1."Person ID",
                                t1."Deduction Date"
                        )ms
                JOIN
                        fernwood.persons p
                        ON p.center||'p'||p.id = ms."Person ID"
                LEFT JOIN
                        fernwood.account_receivables ar 
                        ON ar.customercenter = p.center 
                        AND ar.customerid = p.id 
                        AND ar.ar_type = 4
                LEFT JOIN 
                        fernwood.payment_accounts pac 
                        ON pac.center = ar.center 
                        AND pac.id = ar.id
                LEFT JOIN 
                        fernwood.payment_agreements pag 
                        ON pac.active_agr_center = pag.center 
                        AND pac.active_agr_id = pag.id 
                        AND pac.active_agr_subid = pag.subid
                        AND pag.active = 'true'                
                )t
)
----------Main script-----------                
SELECT
        fl."Person ID",
        fl."Member Name",
        fl."Person Status",
        fl."Renewal amount", 
        fl."Installment plan amount",
        fl."Manual Invoices/Credits amount",
        fl."Overdue amount",       
        fl."Deduction Date",
        CASE
    WHEN fl."Payment Agreement State" IN ('Ended = bank', 'Ended = creditor', 'Failed', 'Ended = clearing house') THEN 0
    WHEN fl."Total Debit BEFORE Renewal" > 0 THEN 0
    ELSE fl."Total Debit BEFORE Renewal"
END AS "Total Debit BEFORE Renewal",
CASE
    WHEN fl."Payment Agreement State" IN ('Ended = bank', 'Ended = creditor', 'Failed', 'Ended = clearing house') THEN 0
    WHEN fl."Total Debit AFTER Renewal" > 0 THEN 0
    ELSE fl."Total Debit AFTER Renewal"
END AS "Total Debit AFTER Renewal",
        fl."Payment Agreement State",
        fl."Clearing House" 
FROM
        FIRST_LIST fl 
UNION ALL
SELECT
        p.center||'p'||p.id AS "Person ID",
        p.fullname AS "Member Name",
        bi_decode_field('PERSONS', 'STATUS', p.status) AS "Person Status",
        0 AS "Renewal amount", 
        0 AS "Installment plan amount",
        0 AS "Manual Invoices/Credits amount",
        0 AS "Overdue amount",       
par.FROM_DATE AS "Deduction Date",
CASE
    WHEN pag.state IN (5, 10) THEN 0
    WHEN ar.balance > 0 THEN 0
    ELSE 0
END AS "Total Debit BEFORE Renewal",
CASE
    WHEN pag.state IN (5, 10) THEN 0
    WHEN ar.balance > 0 THEN 0
    ELSE ar.balance
END AS "Total Debit AFTER Renewal",
        CASE 
                WHEN pag.state = 1 THEN 'Created' 
                WHEN pag.state = 2 THEN 'Sent' 
                WHEN pag.state = 3 THEN 'Failed' 
                WHEN pag.state = 4 THEN 'OK' 
                WHEN pag.state = 5 THEN 'Ended = bank' 
                WHEN pag.state = 6 THEN 'Ended = clearing house' 
                WHEN pag.state = 7 THEN 'Ended = debtor' 
                WHEN pag.state = 8 THEN 'Cancelled = not sent' 
                WHEN pag.state = 9 THEN 'Cancelled = sent' 
                WHEN pag.state = 10 THEN 'Ended = creditor' 
                WHEN pag.state = 11 THEN 'No agreement' 
                WHEN pag.state = 12 THEN 'Cash payment (deprecated)' 
                WHEN pag.state = 13 THEN 'Agreement not needed (invoice payment)' 
                WHEN pag.state = 14 THEN 'Agreement information incomplete' 
                WHEN pag.state = 15 THEN 'Transfer' 
                WHEN pag.state = 16 THEN 'Agreement Recreated' 
                WHEN pag.state = 17 THEN 'Signature missing' 
                ELSE 'UNDEFINED' 
        END AS "Payment Agreement State",
        CASE
                WHEN pag.clearinghouse = 1 THEN 'Bank Account'
                WHEN pag.clearinghouse = 2 THEN 'Credit Card'
        END AS "Clearing House"           
FROM         
        fernwood.persons p
CROSS JOIN PARAMS par        
JOIN
        fernwood.account_receivables ar 
        ON ar.customercenter = p.center 
        AND ar.customerid = p.id 
        AND ar.ar_type = 4
JOIN 
        fernwood.payment_accounts pac 
        ON pac.center = ar.center 
        AND pac.id = ar.id
JOIN 
        fernwood.payment_agreements pag 
        ON pac.active_agr_center = pag.center 
        AND pac.active_agr_id = pag.id 
        AND pac.active_agr_subid = pag.subid
        AND pag.active = 'true' 
WHERE
        p.center||'p'||p.id NOT IN (SELECT "Person ID" FROM FIRST_LIST)
        AND
        p.center IN (:Scope)
        AND 
        ar.balance < 0
        AND
        pag.individual_deduction_day = par.PAYMENT_CYCLE