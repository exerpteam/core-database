SELECT
        t5.CenterName,
        t5.external_id AS Costcenter,
        t5.PersonKey,
        t5.PersonName,
        t5.SubscriptionKey,
        t5.SubscriptionName,
        --t5.salesDate,
        MIN(t5.InvoicedStartDate) AS InvoicedStartDate,
        MAX(t5.InvoicedEndDate) AS InvoicedEndDate,
        SUM(t5.InvoicedAmount) AS InvoicedAmount,
        SUM(CASE WHEN t5.InvoicedAmount>0 THEN t5.InvoicedDays ELSE 0 END) AS InvoicedDays,
        MAX(t5.DailyPrice) AS DailyPrice, 
        SUM(CASE WHEN t5.dayssincestart < 0 THEN 0 ELSE t5.dayssincestart END) AS dayssincestart,
        SUM(t5.historicfreedays) AS historicfreedays,
        SUM(t5.historicfreezedays) AS historicfreezedays,
        SUM(t5.realizeddays) AS realizeddays,
        SUM(CASE WHEN t5.InvoicedAmount>0 THEN t5.deferreddays ELSE 0 END) AS deferreddays,
        SUM(t5.realizedrevenue) AS realizedrevenue,
        SUM(t5.deferredrevenue) AS deferredrevenue,
        t5.subscriptionstart,
        t5.subscriptionend,
        t5.productgroup,
        t5.DEFERREDREVENUESALESACCOUNT as "PL Account", 
        t5.DEFERREDREVENUELIABILITYACCOUNT as "BS Account",
        (CASE
                WHEN t5.inv_text = 'Converted subscription invoice' THEN 'Y'
                ELSE 'N'
        END) AS Migrated,
        t5.inv_text as "Text"
FROM
(
        SELECT
                t4.CenterName                                   AS CenterName,
                t4.external_id,
                t4.PersonKey                                    AS PersonKey,
                t4.PersonName                                   AS PersonName,
                t4.SubscriptionKey                              AS SubscriptionKey,
                t4.SubscriptionName                             AS SubscriptionName,
                t4.InvoicedStartDate                            AS InvoicedStartDate,
                t4.InvoicedEndDate                              AS InvoicedEndDate,
                t4.InvoicedAmount                               AS InvoicedAmount,
                t4.InvoicedDays                                 AS InvoicedDays,
                t4.DailyPrice                                   AS DailyPrice,
                t4.DaysSinceStart                               AS DaysSinceStart,
                t4.SumHistoricFreeDays                          AS HistoricFreeDays,
                t4.SumHistoricFreezeDays                        AS HistoricFreezeDays,  
                t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays AS RealizedDays,
                t4.InvoicedDays-(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays) AS DeferredDays,
                ROUND(t4.RealizedRevenueCalc*(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays)/t4.InvoicedDays,2) AS RealizedRevenue,        
                t4.RealizedRevenueCalc-(ROUND((t4.RealizedRevenueCalc)*(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays)/t4.InvoicedDays,2)) AS DeferredRevenue,
                /*(CASE 
                        WHEN t4.InvoicedDays-(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays)=0 THEN
                                0
                        ELSE       
                                ROUND(((t4.RealizedRevenueCalc-(ROUND(t4.RealizedRevenueCalc*(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays)/t4.InvoicedDays,2)))*
                                LEAST(t4.InvoicedDays-(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays),(trunc(add_months(t4.cutdate+1,1), 'Month')-1)-(t4.cutdate+1)+1))
                                 /(t4.InvoicedDays-(t4.GetDaysSinceStart-t4.SumHistoricFreeDays-t4.SumHistoricFreezeDays)),2)
                 END) AS RevenueReleasedNextMonth,   */  
                t4.SubscriptionStart                            AS SubscriptionStart,
                t4.SubscriptionEnd                              AS SubscriptionEnd,
                t4.ProductGroup                                 AS ProductGroup,
                t4.inv_text,
                t4.DEFERREDREVENUESALESACCOUNT, 
                t4.DEFERREDREVENUELIABILITYACCOUNT
               -- t4.salesDate
        FROM
        (
                SELECT
                        t3.CenterName,
                        t3.external_id,
                        t3.PersonKey,
                        t3.PersonName,
                        t3.SubscriptionKey,
                        t3.SubscriptionName,
                        t3.InvoicedStartDate,
                        t3.InvoicedEndDate,
                        t3.InvoicedAmount AS InvoicedAmount,
                        t3.InvoicedDays,
                        ROUND(( t3.InvoicedAmount)/(t3.InvoicedDays),2) AS DailyPrice,
                        t3.DaysSinceStart,
                        SUM(t3.HistoricFreeDays) AS SumHistoricFreeDays,
                        SUM(t3.HistoricFreezeDays) AS SumHistoricFreezeDays,
                        t3.GetDaysSinceStart,
                        t3.InvoicedAmount AS RealizedRevenueCalc,
                        t3.SubscriptionStart,
                        t3.SubscriptionEnd,                 
                        t3.ProductGroup,
                        t3.cutdate,
                        t3.inv_text,
                        t3.DEFERREDREVENUESALESACCOUNT, 
                        t3.DEFERREDREVENUELIABILITYACCOUNT
                       -- t3.salesDate
                FROM 
                (  
                        SELECT
                                t2.CenterName,
                                t2.external_id,
                                t2.PersonKey,
                                t2.PersonName,
                                t2.SubscriptionKey,
                                t2.SubscriptionName,
                                t2.InvoicedStartDate,
                                t2.InvoicedEndDate,
                                t2.TotalAmount+t2.TotalSponsor AS InvoicedAmount,
                                t2.TotalAmount,
                                t2.TotalSponsor,
                                t2.InvoicedDays,
                                t2.DaysSinceStart, 
                                t2.HistoricFreeDays,
                                t2.HistoricFreezeDays,
                                t2.GetDaysSinceStart,         
                                t2.SubscriptionStart,
                                t2.SubscriptionEnd,                 
                                t2.ProductGroup,
                                t2.cutdate,
                                t2.inv_text,
                                t2.DEFERREDREVENUESALESACCOUNT, 
                                t2.DEFERREDREVENUELIABILITYACCOUNT
                                --t2.salesDate
                        FROM
                        (
                                        SELECT
                                                t1.shortName AS CenterName, 
                                                t1.external_id,
                                                t1.PE_CENTER || 'p' || t1.PE_ID AS PersonKey,
                                                t1.fullname AS PersonName,
                                                t1.SU_CENTER || 'ss' || t1.SU_ID AS SubscriptionKey,
                                                t1.PR_NAME AS SubscriptionName,
                                                t1.SPP_FROM_DATE AS InvoicedStartDate,
                                                t1.SU_BILLED_UNTIL_DATE AS InvoicedEndDate,
                                                COALESCE(t1.NETTOTALCUSTOMER,0) AS TotalAmount,
                                                COALESCE(t1.NETTOTALSPONSOR,0) AS TotalSponsor,
                                                t1.SPP_TO_DATE-t1.SPP_FROM_DATE+1 AS InvoicedDays,
                                                t1.cutDate+1-t1.SPP_FROM_DATE AS DaysSinceStart,
                                                (CASE 
                                                        WHEN (t1.SRP_END_DATE>=t1.SPP_FROM_DATE AND t1.cutDate >=t1.SRP_START_DATE) THEN 
                                                                LEAST(t1.SRP_END_DATE,t1.cutDate)-GREATEST(t1.SPP_FROM_DATE,t1.SRP_START_DATE)+1
                                                        ELSE
                                                                0
                                                END) AS HistoricFreeDays,
                                                (CASE 
                                                        WHEN (t1.SFP_END_DATE>=t1.SPP_FROM_DATE AND t1.cutDate>=t1.SFP_START_DATE) THEN 
                                                                LEAST(t1.SFP_END_DATE,t1.cutDate)-GREATEST(t1.SPP_FROM_DATE,t1.SFP_START_DATE)+1
                                                        ELSE
                                                                0
                                                END) AS HistoricFreezeDays,
                                                (CASE
                                                        WHEN t1.cutDate >= t1.SPP_FROM_DATE THEN
                                                               t1.cutDate - t1.SPP_FROM_DATE + 1
                                                        ELSE 
                                                                0
                                                END) AS GetDaysSinceStart,
                                                t1.SU_START_DATE AS SubscriptionStart,
                                                t1.SU_END_DATE AS SubscriptionEnd, 
                                                t1.pg_name AS ProductGroup,
                                                t1.cutdate,
                                                t1.inv_text,
                                                t1.DEFERREDREVENUESALESACCOUNT, 
                                                t1.DEFERREDREVENUELIABILITYACCOUNT
                                               -- t1.salesDate
                                                
                                        FROM
                                        (
                                                WITH PARAMS AS MATERIALIZED
                                                (
                                                        SELECT
                                                                TO_DATE(:cutDate,'YYYY-MM-DD') AS cutDate,
                                                                dateToLongC(TO_CHAR(TO_DATE(:cutDate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),c.id)-1 AS cutDateLong,
                                                                c.id,
                                                                c.name AS shortName,
                                                                c.external_id
                                                        FROM centers c
                                                )
                                                SELECT 
                                                        par.shortName,
                                                        par.external_id,
                                                        par.cutDate,
                                                        pe.fullname,
                                                        pe.center AS PE_CENTER, 
                                                        pe.id AS PE_ID, 
                                                        su.center AS SU_CENTER, 
                                                        su.id AS SU_ID, 
                                                        su.center || 'ss' || su.id,
                                                        su.start_date AS SU_START_DATE, 
                                                        su.end_date AS SU_END_DATE, 
                                                        su.billed_until_date AS SU_BILLED_UNTIL_DATE, 
                                                        pr.name AS PR_NAME, 
                                                        pr1.name AS PR1_NAME, 
                                                        pr.primary_product_group_id AS PR_PRIMARY_PRODUCT_GROUP_ID, 
                                                        spp.from_date AS SPP_FROM_DATE, 
                                                        spp.to_date AS SPP_TO_DATE, 
                                                        spp.spp_type AS SPP_SPP_TYPE, 
                                                        spp.entry_time AS SPP_ENTRY_TIME, 
                                                        spp.center AS SPP_CENTER, 
                                                        spp.id AS SPP_ID, 
                                                        spp.subid AS SPP_SUBID, 
                                                        pr.ptype AS PR_PTYPE, 
                                                        st.st_type AS ST_ST_TYPE, 
                                                        (CASE 
                                                                WHEN pr.ptype = 13 THEN pr.name 
                                                                ELSE pr1.name 
                                                        END) AS PRODUCTNAME, 
                                                        SUM(il1.net_amount) AS NETTOTALCUSTOMER, 
                                                        MAX(inv.trans_time) AS MAXTRANSTIME, 
                                                        SUM(il2.net_amount) AS NETTOTALSPONSOR, 
                                                        acc_rev.external_id AS DEFERREDREVENUESALESACCOUNT, 
                                                        acc_lia.external_id AS DEFERREDREVENUELIABILITYACCOUNT,
                                                        srp.end_date AS SRP_END_DATE,
                                                        srp.start_date AS SRP_START_DATE,
                                                        sfp.end_date AS SFP_END_DATE,
                                                        sfp.start_date AS SFP_START_DATE,
                                                        pg.name AS pg_name,
                                                        inv.text as inv_text
                                                       -- longtodatec(inv.entry_time, su.center) AS salesDate
                                                FROM puregym_switzerland.subscriptionperiodparts AS spp 
                                                JOIN puregym_switzerland.subscriptions AS su 
                                                        ON (spp.center = su.center AND spp.id = su.id) 
                                                JOIN params par 
                                                        ON par.id = su.center
                                                JOIN puregym_switzerland.persons AS pe 
                                                        ON (su.owner_center = pe.center AND su.owner_id = pe.id) 
                                                JOIN puregym_switzerland.subscriptiontypes AS st 
                                                        ON (su.subscriptiontype_center = st.center AND su.subscriptiontype_id = st.id) 
                                                LEFT JOIN puregym_switzerland.spp_invoicelines_link AS spil 
                                                        ON (spil.period_center = spp.center AND spil.period_id = spp.id AND spil.period_subid = spp.subid) 
                                                LEFT JOIN puregym_switzerland.invoice_lines_mt AS il1 
                                                        ON (spil.invoiceline_center = il1.center AND spil.invoiceline_id = il1.id AND spil.invoiceline_subid = il1.subid) 
                                                LEFT JOIN puregym_switzerland.invoices AS inv 
                                                        ON (il1.center = inv.center AND il1.id = inv.id) 
                                                INNER JOIN puregym_switzerland.products AS pr 
                                                        ON (il1.productcenter = pr.center AND il1.productid = pr.id) 
                                                LEFT JOIN puregym_switzerland.products AS pr1 
                                                        ON (st.center = pr1.center AND st.id = pr1.id) 
                                                LEFT JOIN puregym_switzerland.product_account_configurations AS pac 
                                                        ON pr.product_account_config_id = pac.id 
                                                     JOIN puregym_switzerland.accounts acc_rev
                                                         on pac.defer_rev_account_globalid = acc_rev.globalid and acc_rev.center = pr.center
                                                     JOIN puregym_switzerland.accounts acc_lia
                                                         on pac.defer_lia_account_globalid = acc_lia.globalid and acc_lia.center = pr.center
                                                LEFT JOIN puregym_switzerland.invoice_lines_mt AS il2 
                                                        ON (inv.sponsor_invoice_center = il2.center AND inv.sponsor_invoice_id = il2.id AND il2.subid = il1.sponsor_invoice_subid) 
                                                LEFT JOIN puregym_switzerland.subscription_reduced_period srp
                                                        ON srp.subscription_center = su.center AND srp.subscription_id = su.id AND srp.type!='FREEZE'
                                                                AND srp.end_date >= spp.from_date AND srp.entry_time <= par.cutDateLong AND srp.state = 'ACTIVE'
                                                LEFT JOIN puregym_switzerland.subscription_freeze_period sfp
                                                        ON sfp.subscription_center = su.center AND sfp.subscription_id = su.id 
                                                                AND sfp.end_date >= spp.from_date AND sfp.entry_time <= par.cutDateLong AND sfp.state = 'ACTIVE'     
                                                LEFT JOIN puregym_switzerland.product_group pg
                                                                ON pr.primary_product_group_id = pg.id
                                                WHERE 
                                                        --pe.center = 6004 AND pe.id = 3660 AND
                                                        inv.trans_time < par.cutDateLong AND
                                                        (
                                                                st.st_type <> 2 
                                                                AND su.center IN (:scope) 
                                                                AND 
                                                                (
                                                                        spp.to_date > par.cutDate
                                                                        OR 
                                                                        (
                                                                                st.st_type = 0 
                                                                                AND su.end_date > par.cutDate
                                                                        )
                                                                ) 
                                                                AND spp.entry_time < par.cutDateLong 
                                                                AND 
                                                                (
                                                                        spp.spp_state = 1 
                                                                        OR spp.cancellation_time >= par.cutDateLong 
                                                                        OR 
                                                                        (
                                                                                su.end_date = par.cutDate
                                                                                AND su.sub_state = 6 
                                                                                AND spp.spp_state = 2
                                                                        )
                                                                )
                                                        ) 
                                                GROUP BY 
                                                        par.shortName,
                                                        par.external_id,
                                                        par.cutDate,
                                                        pe.fullname,
                                                        pe.center, 
                                                        pe.id, 
                                                        su.center, 
                                                        su.id, 
                                                        su.start_date, 
                                                        su.end_date, 
                                                        su.billed_until_date, 
                                                        pr.name, 
                                                        pr1.name, 
                                                        pr.primary_product_group_id, 
                                                        spp.from_date, 
                                                        spp.to_date, 
                                                        spp.spp_type, 
                                                        spp.entry_time, 
                                                        spp.center, 
                                                        spp.id, 
                                                        spp.subid, 
                                                        pr.ptype, 
                                                        st.st_type, 
                                                        acc_rev.external_id,
                                                        acc_lia.external_id,
                                                        srp.end_date,
                                                        srp.start_date,
                                                        sfp.end_date,
                                                        sfp.start_date,
                                                        pg_name,
                                                        inv.text
                                                       -- salesDate
                                                ORDER BY 
                                                        pe.center, 
                                                        pe.id, 
                                                        spp.center, 
                                                        spp.id, 
                                                        ProductName, 
                                                        spp.subid
                                        ) t1
                        ) t2
                ) t3
                        GROUP BY
                                t3.CenterName,
                                t3.external_id,
                                t3.PersonKey,
                                t3.PersonName,
                                t3.SubscriptionKey,
                                t3.SubscriptionName,
                                t3.InvoicedStartDate,
                                t3.InvoicedEndDate,
                                t3.InvoicedAmount,
                                t3.InvoicedDays,
                                t3.DaysSinceStart,
                                t3.GetDaysSinceStart,
                                t3.SubscriptionStart,
                                t3.SubscriptionEnd,
                                t3.ProductGroup,
                                t3.cutdate,
                                t3.inv_text,
                                t3.DEFERREDREVENUESALESACCOUNT, 
                                t3.DEFERREDREVENUELIABILITYACCOUNT
                               -- t3.salesDate
        ) t4
) t5
GROUP BY
        t5.CenterName,
        t5.external_id,
        t5.PersonKey,
        t5.PersonName,
        t5.SubscriptionKey,
        t5.SubscriptionName,
       -- t5.salesDate,
        t5.subscriptionstart,
        t5.subscriptionend,
        t5.productgroup,
        t5.inv_text,
        t5.DEFERREDREVENUESALESACCOUNT, 
        t5.DEFERREDREVENUELIABILITYACCOUNT
        
        
              
      