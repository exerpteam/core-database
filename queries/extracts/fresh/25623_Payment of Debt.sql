-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t5.year_paydebt AS period,
        t5.country,
        t5.total_amount_web_apps_payment_method AS total_amount_webapps,
        t5.average_web_due_date AS average_overdue_days_webapps,
        ROUND((t5.total_amount_web_apps_payment_method*100)/(t5.total_amount_web_apps_payment_method + t5.total_amount_inkasso_payment_method + t5.total_amount_other_payment_method),2) AS percentage_webapps,
        t5.total_amount_inkasso_payment_method AS total_amount_inkasso,
        t5.average_inkasso_due_date AS average_overdue_days_inkasso,
        ROUND((t5.total_amount_inkasso_payment_method*100)/(t5.total_amount_web_apps_payment_method + t5.total_amount_inkasso_payment_method + t5.total_amount_other_payment_method),2) AS percentage_inkasso,
        t5.total_amount_other_payment_method AS total_amount_other,
        t5.average_other_due_date AS average_overdue_days_other,
        ROUND((t5.total_amount_other_payment_method*100)/(t5.total_amount_web_apps_payment_method + t5.total_amount_inkasso_payment_method + t5.total_amount_other_payment_method),2) AS percentage_other
FROM
(

        SELECT
                t4.year_paydebt,
                t4.country,
                ROUND(t4.web_apps_payment_method,2) AS total_amount_web_apps_payment_method,
                ROUND(
                        CAST((CASE 
                                WHEN t4.web_transactions_to_count = 0 THEN 0 
                                ELSE t4.web_sum_overdue_days / t4.web_transactions_to_count 
                        END) AS NUMERIC)
                ,2) AS average_web_due_date,
                ROUND(t4.inkasso_payment_method,2) AS total_amount_inkasso_payment_method,
                ROUND(
                        CAST((CASE 
                                WHEN t4.inkasso_transactions_to_count = 0 THEN 0
                                ELSE t4.inkasso_sum_overdue_days / t4.inkasso_transactions_to_count 
                        END ) AS NUMERIC)
                ,2) AS average_inkasso_due_date,
                ROUND(t4.other_payment_method,2) AS total_amount_other_payment_method,
                ROUND(
                        CAST((CASE
                                WHEN t4.other_transactions_to_count = 0 THEN 0 
                                ELSE t4.other_sum_overdue_days / t4.other_transactions_to_count 
                        END) AS NUMERIC)
                ,2) AS average_other_due_date        
        FROM
        (
                SELECT
                        t3.year_paydebt,
                        t3.country,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Web' THEN t3.amount
                                ELSE 0
                        END) AS web_apps_payment_method,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Inkasso' THEN t3.amount
                                ELSE 0
                        END) AS inkasso_payment_method,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Other' THEN t3.amount
                                ELSE 0
                        END) AS other_payment_method,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Web' AND t3.total_days_overdue IS NOT NULL THEN 1
                                ELSE 0
                        END) AS web_transactions_to_count,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Inkasso' AND t3.total_days_overdue IS NOT NULL THEN 1
                                ELSE 0
                        END) AS inkasso_transactions_to_count,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Other' AND t3.total_days_overdue IS NOT NULL THEN 1
                                ELSE 0
                        END) AS other_transactions_to_count,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Web' AND t3.total_days_overdue IS NOT NULL THEN t3.total_days_overdue
                                ELSE 0
                        END) AS web_sum_overdue_days,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Inkasso' AND t3.total_days_overdue IS NOT NULL THEN t3.total_days_overdue
                                ELSE 0
                        END) AS inkasso_sum_overdue_days,
                        SUM(CASE
                                WHEN t3.paydebtmethod = 'Other' AND t3.total_days_overdue IS NOT NULL THEN t3.total_days_overdue
                                ELSE 0
                        END) AS other_sum_overdue_days
                FROM
                (
                        SELECT
                                t2.*,
                                (CASE WHEN EXTRACT(DAY FROM T2.days_overdue) > 0 THEN EXTRACT(DAY FROM T2.days_overdue)
                                        ELSE NULL
                                END) AS total_days_overdue,
                                TO_CHAR(t2.entry_datetime,'YYYY-MM') AS year_paydebt
                        FROM
                        (
                                SELECT
                                        t1.*,
                                        t1.entry_datetime - t1.DueDate AS days_overdue
                                FROM
                                (
                                        WITH params AS MATERIALIZED
                                        (
                                                SELECT 
                                                        dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'),c.id) AS fromDate,
                                                        dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD')+ interval '1 days','YYYY-MM-DD'),c.id)-1 AS toDate,
                                                        c.id,
                                                        c.country
                                                FROM centers c
                                        )
                                        SELECT
                                                ar.customercenter || 'p' || ar.customerid AS personid,
                                                art.center,
                                                art.id,
                                                art.subid,
                                                art.amount, 
                                                longtodateC(art.entry_time,art.center) AS entry_datetime, 
                                                MIN(art2.due_date) AS DueDate,
                                                (CASE
                                                        WHEN (art.employeecenter,art.employeeid) IN ((200,28404)) THEN 'Web'
                                                        WHEN (art.text LIKE 'Innbetaling via inkassobyrå%') THEN 'Inkasso'
                                                        ELSE 'Other'
                                                END) AS paydebtmethod,
                                                p.fullname,
                                                art.text,
                                                p.fullname,
                                                par.country
                                        FROM ar_trans art
                                        JOIN params par 
                                                ON par.id = art.center
                                        JOIN account_receivables ar
                                                ON art.center = ar.center AND art.id = ar.id
                                        JOIN art_match atm
                                                ON atm.art_paying_center = art.center AND atm.art_paying_id = art.id AND atm.art_paying_subid = art.subid
                                        JOIN ar_trans art2
                                                ON atm.art_paid_center = art2.center AND atm.art_paid_id = art2.id AND atm.art_paid_subid = art2.subid   
                                        JOIN employees emp
                                                ON art.employeecenter = emp.center AND art.employeeid = emp.id 
                                        JOIN persons p
                                                ON emp.personcenter = p.center AND emp.personid = p.id
                                        WHERE
                                                art.amount > 0     
                                                AND art.entry_time BETWEEN par.fromDate AND par.toDate
                                                AND 
                                                (
                                                        art.text LIKE 'Innbetaling via inkassobyrå%'
                                                        OR art.text = 'Cash collection payment received'
                                                        OR art.text LIKE 'Innbetaling til konto%' 
                                                        OR art.text LIKE 'API Register remaining money from payment request%'
                                                        OR art.text LIKE  'Manuell betalingsregistrering:%'
                                                        OR art.text LIKE'Manuell betalingsregistrering: Payment open request%'
                                                )
                                                AND atm.cancelled_time IS NULL
                                        GROUP BY        
                                                ar.customercenter,
                                                ar.customerid, 
                                                art.amount, 
                                                art.trans_time,
                                                art.center,
                                                art.employeecenter,
                                                art.employeeid,
                                                p.fullname,
                                                art.center,
                                                art.id,
                                                art.subid,
                                                art.text,
                                                par.country
                                ) t1
                        ) t2
                ) t3
                GROUP BY 
                        t3.year_paydebt,
                        t3.country
        ) t4
) t5
ORDER BY 1,2