SELECT DISTINCT

    
    t."Old Person Id",
    t."New Person Id",
    t."External Id",
    t."Originating Subscription Number",
    t."Destination Subscription Number",
    t."Transfer Date",
    t."Originating Club Number",
    t."Originating Club Name",
    t."Destination Club Number",
    t."Destination Club Name",
    t."Subscription Type",
    t."Primary Product Group",
    t."Product Name",
    t."Full Contract Value",
    t."Subscription Start Date",
    t."Subscription End Date",
    t."Subscription Price (Net)",
    t."Subscription Price (Total)",
    t."Previous Subscription Start Date",
    t."Previous Subscription End Date",
    t."Realized Amount (Net)",
    t."Realized Amount (Total)",
    t."New Subscription Start Date",
    t."New Subscription End Date",
    t."Remaining Amount (Net)",
    t."Remaining Amount (Total)"
    ,t.end_date_with_free_old AS "Old Subscription End Date (With free period)"
    ,t.end_date_with_free "New Subscription End Date (With free period)"
    
FROM

    (
        SELECT DISTINCT
        
            oldsub.owner_center || 'p' || oldsub.owner_id                                                         AS "Old Person Id",
            newsub.owner_center || 'p' || newsub.owner_id                                                         AS "New Person Id",
            p.external_id                                                                                         AS "External Id",
            oldsub.center || 'ss' || oldsub.id                                                                    AS "Originating Subscription Number",
            newsub.center || 'ss' || newsub.id                                                                    AS "Destination Subscription Number",
            newsub.center,
            newsub.id,
            sc.effect_date                                                                                        AS "Transfer Date",
            fromcenter.id                                                                                         AS "Originating Club Number",
            fromcenter.NAME                                                                                       AS "Originating Club Name",
            tocenter.id                                                                                           AS "Destination Club Number",
            tocenter.NAME                                                                                         AS "Destination Club Name",
            'CASH/PIF'                                                                                            AS "Subscription Type",
            pg.name                                                                                               AS "Primary Product Group",
            COALESCE(oldcancelil.total_amount, 0) + COALESCE(oldsponcancelil.total_amount, 0)                     AS "Full Contract Value",
            oldsppcancel.from_date                                                                                AS "Subscription Start Date",
            oldsppcancel.to_date                                                                                 AS "Subscription End Date",
            COALESCE(srp1.end_date,oldsppcancel.to_date) AS end_date_with_free_old,
            COALESCE(oldcancelil.net_amount, 0) + COALESCE(oldsponcancelil.net_amount, 0)                         AS "Subscription Price (Net)",
            COALESCE(oldcancelil.total_amount, 0) + COALESCE(oldsponcancelil.total_amount, 0)                     AS "Subscription Price (Total)",
            oldsppactive.from_date                                                                                AS "Previous Subscription Start Date",
            oldsppactive.to_date                                                                                  AS "Previous Subscription End Date",
            COALESCE(oldactiveil.net_amount, 0) + COALESCE(oldsponactiveil.net_amount, 0)                         AS "Realized Amount (Net)",
            COALESCE(oldactiveil.total_amount, 0) + COALESCE(oldsponactiveil.total_amount, 0)                     AS "Realized Amount (Total)",
            newsppactive.from_date                                                                                AS "New Subscription Start Date",
            COALESCE(
                MAX(srp.end_date) OVER (PARTITION BY newsppactive.center,newsppactive.id)
                ,newsppactive.to_date
            ) AS end_date_with_free,
            MAX(newsppactive.to_date) OVER (PARTITION BY newsppactive.center,newsppactive.id) AS "New Subscription End Date",
            COALESCE(newactiveil.net_amount, 0) + COALESCE(newsponactiveil.net_amount, 0)                         AS "Remaining Amount (Net)",
            COALESCE(newactiveil.total_amount, 0) + COALESCE(newsponactiveil.total_amount, 0)                     AS "Remaining Amount (Total)",
            rank() over (partition BY oldsppcancel.center, oldsppcancel.id ORDER BY oldsppcancel.entry_time,srp1.cancel_time DESC) AS rnk,
            pd.name AS "Product Name"
        
      
        FROM
        
            subscriptions oldsub
        
        JOIN  subscription_change sc
        ON sc.old_subscription_center = oldsub.center
        AND sc.old_subscription_id = oldsub.id
        AND sc.type = 'TRANSFER'
        
        JOIN  subscriptiontypes oldst
        ON oldst.center = oldsub.subscriptiontype_center
        AND oldst.id = oldsub.subscriptiontype_id
        AND oldst.st_type = 0
        
        JOIN  subscriptions newsub
        ON newsub.center = oldsub.transferred_center
        AND newsub.id = oldsub.transferred_id
        
        JOIN  persons p
        ON p.center = newsub.owner_center
        AND p.id = newsub.owner_id
        
        JOIN  subscriptiontypes newst
        ON newst.center = newsub.subscriptiontype_center
        AND newst.id = newsub.subscriptiontype_id
        
        JOIN  centers fromcenter
        ON fromcenter.ID=oldsub.owner_center
        
        JOIN  centers tocenter
        ON tocenter.ID=newsub.owner_center
        
        JOIN  products pd
        ON pd.center = newst.center
        AND pd.id = newst.id
        
        JOIN  product_group pg
        ON pg.id = pd.primary_product_group_id
        
        /* Cancelled sub period part and their invoice */
        
            JOIN  subscriptionperiodparts oldsppcancel
            ON oldsppcancel.center = oldsub.center
            AND oldsppcancel.id = oldsub.id
            AND oldsppcancel.spp_state = 2

            JOIN  spp_invoicelines_link oldcancellink
            ON oldcancellink.period_center = oldsppcancel.center
            AND oldcancellink.period_id = oldsppcancel.id
            AND oldcancellink.period_subid = oldsppcancel.subid

            JOIN  invoice_lines_mt oldcancelil
            ON oldcancelil.center = oldcancellink.invoiceline_center
            AND oldcancelil.id = oldcancellink.invoiceline_id
            AND oldcancelil.subid = oldcancellink.invoiceline_subid

            JOIN  invoices oldcancelinv
            ON oldcancelinv.center = oldcancelil.center
            AND oldcancelinv.id = oldcancelil.id
        
            LEFT JOIN subscription_reduced_period srp1
            ON srp1.subscription_center = oldsppcancel.center
            AND srp1.subscription_id = oldsppcancel.id
            -- AND srp1.state = 'ACTIVE'
        
        /* Trnasfered active sub period part and their invoice */
        
            LEFT JOIN  subscriptionperiodparts newsppactive
            ON newsppactive.center = newsub.center
            AND newsppactive.id = newsub.id
            AND newsppactive.spp_state = 1
            AND newsppactive.spp_type = 1

            LEFT JOIN  spp_invoicelines_link newactivelink
            ON newactivelink.period_center = newsppactive.center
            AND newactivelink.period_id = newsppactive.id
            AND newactivelink.period_subid = newsppactive.subid

            LEFT JOIN  invoice_lines_mt newactiveil
            ON newactiveil.center = newactivelink.invoiceline_center
            AND newactiveil.id = newactivelink.invoiceline_id
            AND newactiveil.subid = newactivelink.invoiceline_subid

            LEFT JOIN  invoices newactiveinv
            ON newactiveinv.center = newactiveil.center
            AND newactiveinv.id = newactiveil.id
        
            LEFT JOIN subscription_reduced_period srp
            ON srp.subscription_center = newsppactive.center
            AND srp.subscription_id = newsppactive.id
            AND srp.state = 'ACTIVE'
        
        /* Used sub period part if there is one and their invoice */
        
            LEFT JOIN  subscriptionperiodparts oldsppactive
            ON oldsppactive.center = oldsub.center
            AND oldsppactive.id = oldsub.id
            AND oldsppactive.spp_state = 1

            LEFT JOIN  spp_invoicelines_link oldactivelink
            ON oldactivelink.period_center = oldsppactive.center
            AND oldactivelink.period_id = oldsppactive.id
            AND oldactivelink.period_subid = oldsppactive.subid

            LEFT JOIN  invoice_lines_mt oldactiveil
            ON oldactiveil.center = oldactivelink.invoiceline_center
            AND oldactiveil.id = oldactivelink.invoiceline_id
            AND oldactiveil.subid = oldactivelink.invoiceline_subid

            LEFT JOIN  invoices oldactiveinv
            ON oldactiveinv.center = oldactiveil.center
            AND oldactiveinv.id = oldactiveil.id
        
        /* All sponsored invoices from above */
        
            LEFT JOIN  invoice_lines_mt oldsponcancelil
            ON oldsponcancelil.center = oldcancelinv.sponsor_invoice_center
            AND oldsponcancelil.id = oldcancelinv.sponsor_invoice_id
            AND oldsponcancelil.subid = oldcancelil.sponsor_invoice_subid

            LEFT JOIN  invoice_lines_mt newsponactiveil
            ON newsponactiveil.center = newactiveinv.sponsor_invoice_center
            AND newsponactiveil.id = newactiveinv.sponsor_invoice_id
            AND newsponactiveil.subid = newactiveil.sponsor_invoice_subid

            LEFT JOIN  invoice_lines_mt oldsponactiveil
            ON oldsponactiveil.center = oldactiveinv.sponsor_invoice_center
            AND oldsponactiveil.id = oldactiveinv.sponsor_invoice_id
            AND oldsponactiveil.subid = oldactiveil.sponsor_invoice_subid
        
        WHERE
        
        oldsub.sub_state = 6 -- Transferred
        AND newsub.center IN ($$Scope$$)
        AND sc.effect_date BETWEEN $$TransferDateFrom$$ and $$TransferDateTo$$ 
    
    ) t

WHERE

    t.rnk = 1
