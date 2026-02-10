-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                t1.*,
                dateToLongC(to_char(t1.toDate + interval '1 days','YYYY-MM-DD'),t1.id)-1 AS toDateLong
        FROM
        (
                SELECT
						TO_DATE(:fromDate,'YYYY-MM-DD') AS fromDate,
						TO_DATE(:toDate,'YYYY-MM-DD') AS toDate,
						c.id,
						c.name
				FROM centers c
				WHERE
						c.id IN (:Scope)
        ) t1
),
debtors AS
(
        SELECT
                DISTINCT 
                ccc.personcenter,
                ccc.personid
        FROM cashcollectioncases ccc
        JOIN params par ON ccc.personcenter = par.id
        WHERE
                ccc.missingpayment = true
                AND ccc.start_datetime < par.toDateLong
                AND (ccc.closed_datetime IS NULL OR ccc.closed_datetime > par.toDateLong)
)
SELECT
        t3.center_name,
        t3.center_id,
        t3.person_id,
        t3.subscription_id,
        t3.product_name,
        t3.subscription_startdate,
        t3.subscription_enddate,
        t3.InvoicedStartDate,
        t3.InvoiceEndDate,
        t3.InvoiceDaysForPeriod,
        (CASE t3.spp_type 
                WHEN 1 THEN 'NORMAL' 
                WHEN 2 THEN 'UNCONDITIONAL FREEZE' 
                WHEN 3 THEN 'FREE DAYS' 
                WHEN 7 THEN 'CONDITIONAL FREEZE' 
                WHEN 8 THEN 'INITIAL PERIOD' 
                WHEN 9 THEN 'PRORATA PERIOD' 
                ELSE 'Undefined' 
        END) AS spp_type,
        t3.SumFreeDays,
        t3.SumFreezeDays,
        t3.InvoicedDays AS spp_invoiceDays,
        t3.InvoicedAmount AS spp_invoiceAmount,
        ROUND(t3.DailyPrice,2) AS daily_price,
        ROUND(t3.DailyPrice*(t3.InvoiceDaysForPeriod-t3.SumFreeDays-t3.SumFreezeDays),2) AS RealizedRevenue,
        (CASE scl.stateid 
                WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' 
        END) AS person_status,
        (CASE 
                WHEN debt.personcenter IS NOT NULL THEN 'Yes'
                ELSE 'No'
        END) debt_case_at_period_end,
t3.text
FROM
(
        SELECT
                t2.center_name,
                t2.center_id,
                t2.person_id,
                t2.subscription_id,
                t2.product_name,
                t2.InvoicedDays,
                t2.InvoicedStartDate,
                t2.InvoiceEndDate,
                t2.InvoicedAmount,
                t2.subscription_startdate,
                t2.subscription_enddate,
                t2.spp_type,
                t2.InvoicedAmount/t2.InvoicedDays AS DailyPrice,  
                t2.InvoiceEndDate - t2.InvoicedStartDate + 1 AS InvoiceDaysForPeriod,
                SUM(t2.FreeDays) AS SumFreeDays,
                SUM(t2.FreezeDays) AS SumFreezeDays,
                t2.pcenter,
                t2.pid,
                t2.scenter,
t2.text
        FROM
        (
                SELECT
                        t1.*,
                        --t1.InvoiceEndDate - t1.InvoicedStartDate + 1 AS InvoicedDays,
                        t1.TotalAmount - t1.VatCustomer + t1.TotalSponsor - t1.VATSponsor AS InvoicedAmount,
                        (CASE
                                WHEN srp.id IS NOT NULL THEN
                                        least(srp.end_date, t1.InvoiceEndDate) - greatest(srp.start_date, t1.InvoicedStartDate) + 1
                                ELSE 
                                        0                
                        END) AS FreeDays,
                        (CASE
                                WHEN sfp.id IS NOT NULL THEN
                                        least(sfp.end_date, t1.InvoiceEndDate) - greatest(sfp.start_date, t1.InvoicedStartDate) + 1
                                ELSE 
                                        0                
                        END) AS FreezeDays
                FROM
                (
                        SELECT
                                par.name AS center_name,
                                par.id AS center_id,
                                p.center || 'p' || p.id AS person_id,
                                s.center || 'ss' || s.id AS subscription_id,
                                s.center AS scenter,
                                s.id AS sid,
                                pr2.name AS product_name,
                                spp.from_date,
                                spp.to_date,
                                s.start_date AS subscription_startdate,
                                s.end_date AS subscription_enddate,
                                s.billed_until_date,
                                spp.spp_type,
                                spp.to_date-spp.from_date+1 AS InvoicedDays,
                                greatest(par.fromDate, spp.from_date) AS InvoicedStartDate,
                                least(par.toDATE, spp.to_date) AS InvoiceEndDate,
                                coalesce(SUM(il.total_amount),0) AS TotalAmount,
                                coalesce(SUM(act.amount),0) AS VatCustomer,
                                coalesce(SUM(ils.total_amount),0) AS TotalSponsor,
                                coalesce(SUM(acts.amount),0) AS VATSponsor,
                                p.center AS pcenter,
                                p.id AS pid,
i.text
                        FROM subscriptionperiodparts spp
                        JOIN params par 
                                ON spp.center = par.id
                        JOIN subscriptions s
                                ON spp.center = s.center AND spp.id = s.id
                        JOIN persons p
                                ON s.owner_center = p.center AND s.owner_id = p.id
                        JOIN subscriptiontypes st
                                ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
                        JOIN products pr1
                                ON pr1.center = st.center AND pr1.id = st.id
                        LEFT JOIN spp_invoicelines_link spil
                                ON spil.period_center = spp.center AND spil.period_id = spp.id AND spil.period_subid = spp.subid
                        LEFT JOIN invoice_lines_mt il
                                ON il.center = spil.invoiceline_center AND il.id = spil.invoiceline_id AND il.subid = spil.invoiceline_subid
                        LEFT JOIN invoices i
                                ON i.center = il.center AND i.id = il.id
                        LEFT JOIN products pr2
                                ON il.productcenter = pr2.center AND il.productid = pr2.id
                        LEFT JOIN invoicelines_vat_at_link ilvat
                                ON ilvat.invoiceline_center = il.center AND ilvat.invoiceline_id = il.id AND ilvat.invoiceline_subid = il.subid
                        LEFT JOIN account_trans act
                                ON act.center = ilvat.account_trans_center AND act.id = ilvat.account_trans_id AND act.subid = ilvat.account_trans_subid
                        LEFT JOIN invoice_lines_mt ils
                                ON ils.center = i.sponsor_invoice_center AND ils.id = i.sponsor_invoice_id AND ils.subid = il.sponsor_invoice_subid
                        LEFT JOIN invoicelines_vat_at_link ilvats
                                ON ilvats.invoiceline_center = ils.center AND ilvats.invoiceline_id = ils.id AND ilvats.invoiceline_subid = ils.subid
                        LEFT JOIN account_trans acts
                                ON acts.center = ilvats.account_trans_center and acts.id = ilvats.account_trans_id AND acts.subid = ilvats.account_trans_subid
                        WHERE
                                --spp.spp_type IN (1,8) -- 1: NORMAL ; 8: INITIAL PERIOD
                                --AND 
                                spp.spp_state = 1 -- 1: ACTIVE
                                AND spp.from_date <= par.toDate
                                AND spp.to_date >= par.fromDate
                        GROUP BY
                                par.name,
                                par.id,
                                p.center,
                                p.id,
                                s.center,
                                s.id,
                                pr2.name,
                                spp.from_date,
                                spp.to_date,
                                s.billed_until_date,
                                par.fromDate,
                                spp.from_date,
                                par.toDate,
                                spp.to_date,
                                s.start_date,
                                s.end_date,
                                spp.spp_type,
i.text
                ) t1
                LEFT JOIN subscription_reduced_period srp   
                        ON srp.subscription_center = t1.scenter AND srp.subscription_id = t1.sid AND srp.type NOT IN ('FREEZE') 
                        AND srp.start_date <= t1.InvoiceEndDate AND srp.end_date >= t1.InvoicedStartDate AND srp.state = 'ACTIVE'
                LEFT JOIN subscription_freeze_period sfp   
                        ON sfp.subscription_center = t1.scenter AND sfp.subscription_id = t1.sid AND sfp.start_date <= t1.InvoiceEndDate 
                        AND sfp.end_date >= t1.InvoicedStartDate AND sfp.state = 'ACTIVE'
        ) t2
        GROUP BY
                t2.center_name,
                t2.center_id,
                t2.person_id,
                t2.subscription_id,
                t2.product_name,
                t2.InvoicedDays,
                t2.InvoicedStartDate,
                t2.InvoiceEndDate,
                t2.InvoicedAmount,
                t2.subscription_startdate,
                t2.subscription_enddate,
                t2.spp_type,
                t2.pcenter,
                t2.pid,
                t2.scenter,
t2.text
) t3
JOIN params par
        ON par.id = t3.scenter
LEFT JOIN state_change_log scl
        ON scl.center = t3.pcenter AND scl.id = t3.pid AND scl.entry_type = 1 AND scl.entry_start_time < par.toDateLong AND (scl.entry_end_time IS NULL OR scl.entry_end_time > par.toDateLong)
LEFT JOIN debtors debt
        ON debt.personcenter = t3.pcenter AND debt.personid = t3.pid