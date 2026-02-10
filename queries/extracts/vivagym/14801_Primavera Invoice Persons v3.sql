-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
        SELECT
                TO_CHAR(current_timestamp,'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
                CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days','YYYY-MM-DD'),c.id) AS BIGINT) AS fromDate,
                CAST(dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD'),'YYYY-MM-DD'),c.id)-1 AS BIGINT) AS toDate,
                c.id AS center_id
        FROM
                CENTERS c
        WHERE
                c.country = 'PT'
),
v_main AS
(
        -- NO PAYMENT ACCOUNT
        SELECT  
                ------------------------ INVOICE MASTER ------------------------
                CAST(extract(YEAR FROM longToDateC(i.entry_time, i.center)) AS TEXT) || 'U' AS serie,
                longToDateC(i.entry_time, i.center) AS paymentDate, -- THEY ARE PAID AUTOMATICALLY
                il.center || 'inv' || il.id AS Referencia,
                i.fiscal_export_token AS CDU_ExerpID,
                SUM(il.total_amount) OVER (partition BY i.center, i.id) AS CDU_ExerpTotalDocument,
                longToDateC(i.trans_time, i.center) AS DueDate, -- NO DUE DATE FOR TRANSACTIONS THAT DO NOT REACH THE PAYMENT ACCOUNT
                payer.center AS person_center,
                payer.id AS person_id,
                il.center AS inv_center,
                il.id AS inv_id,
                crt.coment AS CDU_EasyPayID, --captureID from EasyPay
                par.batch_id,
                ------------------------ INVOICE DETAILS ------------------------
                prod.external_id AS Artigo,
                il.text AS Descricao,
                (CASE
                        WHEN ilvt.rate IS NOT NULL THEN CAST(ilvt.rate*100 AS INT)
                        ELSE '0'
                END) AS codiva,
                ROUND(il.total_amount,2) AS UnitPrice,
                0 AS LineDiscount,
                il.quantity AS Quantity,
                COALESCE(spp.from_date,longToDateC(i.trans_time, i.center)) AS Start_date_period,
                COALESCE(spp.to_date,longToDateC(i.trans_time, i.center)) AS End_date_period,
                (CASE
                        WHEN spp.from_date IS NOT NULL THEN 'true'
                        ELSE 'false' 
                END) AS specialization,
                il.subid AS invl_subid    
        FROM vivagym.invoices i
        JOIN params par
                ON par.center_id = i.center
        JOIN invoice_lines_mt il
                ON il.center = i.center AND il.id = i.id
        JOIN vivagym.products prod
                ON prod.center = il.productcenter AND prod.id = il.productid
        LEFT JOIN vivagym.ar_trans art
                ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
        LEFT JOIN vivagym.spp_invoicelines_link spl
                ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
        LEFT JOIN vivagym.subscriptionperiodparts spp
                ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
        LEFT JOIN vivagym.product_group pg
                ON pg.ID = prod.primary_product_group_id
        LEFT JOIN vivagym.persons p
                ON p.center = il.person_center AND p.id = il.person_id
        LEFT JOIN vivagym.persons payer
                ON payer.center = i.payer_center AND payer.id = i.payer_id
        LEFT JOIN vivagym.invoicelines_vat_at_link ilvt
                ON ilvt.invoiceline_center = il.center AND ilvt.invoiceline_id = il.id AND ilvt.invoiceline_subid = il.subid
        LEFT JOIN vivagym.cashregistertransactions crt
                ON crt.paysessionid = i.paysessionid
        WHERE
                payer.SEX != 'C'
                AND il.net_amount != '0'
                AND art.center IS NULL
                AND i.entry_time between par.fromDate AND par.toDate
        UNION ALL
        -------------------------- PAYMENT ACCOUNT -----------------------
        SELECT
                t1.serie,
                t1.paymentDate,
                t1.Referencia,
                t1.CDU_ExerpID,
                t1.total_settled_amount AS CDU_ExerpTotalDocument,
                t1.DueDate,
                t1.person_center,
                t1.person_id,
                t1.inv_center,
                t1.inv_id,
                pr.clearinghouse_payment_ref AS CDU_EasyPayID,
                par2.batch_id,
                -------------------- INVOICE DETAILS --------------------
                prod.external_id AS Artigo,
                il.text AS Descricao,
                (CASE
                        WHEN ilvt.rate IS NOT NULL THEN CAST(ilvt.rate*100 AS INT)
                        ELSE '0'
                END) AS codiva,
                ROUND(il.total_amount,2) AS UnitPrice,
                0 AS LineDiscount,
                il.quantity AS Quantity,
                COALESCE(spp.from_date, t1.paymentDate) AS Start_date_period,
                COALESCE(spp.to_date, t1.paymentDate) AS End_date_period,
                (CASE
                        WHEN spp.from_date IS NOT NULL THEN 'true'
                        ELSE 'false' 
                END) AS specialization,
                il.subid AS invl_subid                
        FROM
        (
                SELECT
                        -------------------- INVOICE MASTER -------------------- 
                        CAST(extract(YEAR FROM longToDateC(MIN(artm.entry_time), i.center)) AS TEXT) || 'P' AS serie,
                        longToDateC(MIN(artm.entry_time), i.center) AS paymentDate, -- THIS IS NOT 100% CORRECT AS THIS IS WHEN THE SETTLEMENT HAPPENS (PROBABLY ONE DAY BEFORE PAYMENT WAS DONE)
                        i.center || 'inv' || i.id AS Referencia,
                        i.fiscal_export_token AS CDU_ExerpID,
                        SUM(artm.amount) AS total_settled_amount,
                        COALESCE(art.due_date, longToDateC(i.trans_time, i.center)) AS DueDate, -- NOT ALL TRANSATIONS WILL HAVE DUEDATE. THOSE THAT DO NOT MAKE IT INTO A PAYMENT REQUEST WILL NOT.
                        payer.center AS person_center,
                        payer.id AS person_id,
                        i.center AS inv_center,
                        i.id AS inv_id,
                        art.payreq_spec_center,
                        art.payreq_spec_id,
                        art.payreq_spec_subid
                FROM vivagym.invoices i
                JOIN params par
                        ON par.center_id = i.center
                JOIN vivagym.ar_trans art
                        ON art.ref_center = i.center AND art.ref_id = i.id AND art.ref_type = 'INVOICE'
                JOIN vivagym.art_match artm 
                        ON art.center = artm.art_paid_center AND art.id = artm.art_paid_id AND art.subid = artm.art_paid_subid
                JOIN vivagym.persons payer
                        ON payer.center = i.payer_center AND payer.id = i.payer_id
                -- check for an scenario wher a PRS can have multipla paymen reuqest of type payments, if so this is not a good solution
                WHERE
                        payer.sex != 'C'
                        AND artm.entry_time between par.fromDate AND par.toDate
                        AND art.amount != 0
                GROUP BY
                        i.center,
                        i.id,
                        i.fiscal_export_token,
                        art.due_date,
                        i.trans_time,
                        payer.center,
                        payer.id,
                        art.payreq_spec_center,
                        art.payreq_spec_id,
                        art.payreq_spec_subid
        ) t1
        JOIN params par2
                ON par2.center_id = t1.inv_center
        JOIN vivagym.invoice_lines_mt il
                ON il.center = t1.inv_center AND il.id = t1.inv_id
        JOIN vivagym.products prod
                ON prod.center = il.productcenter AND prod.id = il.productid
        LEFT JOIN vivagym.spp_invoicelines_link spl
                ON spl.invoiceline_center = il.center AND spl.invoiceline_id = il.id AND spl.invoiceline_subid = il.subid
        LEFT JOIN vivagym.subscriptionperiodparts spp
                ON spl.period_center = spp.center AND spl.period_id = spp.id AND spl.period_subid = spp.subid
        LEFT JOIN vivagym.invoicelines_vat_at_link ilvt
                ON ilvt.invoiceline_center = il.center AND ilvt.invoiceline_id = il.id AND ilvt.invoiceline_subid = il.subid
        LEFT JOIN payment_request_specifications prs
                ON t1.payreq_spec_center = prs.center AND t1.payreq_spec_id = prs.id AND t1.payreq_spec_subid = prs.subid
        LEFT JOIN vivagym.payment_requests pr
                ON pr.inv_coll_center = prs.center AND pr.inv_coll_id = prs.id AND pr.inv_coll_subid = prs.subid AND pr.request_type = 1
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(Artigo,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo2,
                LEAD(Descricao,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao2,
                LEAD(codiva,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva2,
                LEAD(UnitPrice,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice2,
                LEAD(LineDiscount,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount2,
                LEAD(Quantity,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity2,
                LEAD(Start_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period2,
                LEAD(End_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period2,
                LEAD(specialization,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization2,
                
                LEAD(Artigo,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo3,
                LEAD(Descricao,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao3,
                LEAD(codiva,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva3,
                LEAD(UnitPrice,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice3,
                LEAD(LineDiscount,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount3,
                LEAD(Quantity,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity3,
                LEAD(Start_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period3,
                LEAD(End_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period3,
                LEAD(specialization,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization3,

                LEAD(Artigo,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo4,
                LEAD(Descricao,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao4,
                LEAD(codiva,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva4,
                LEAD(UnitPrice,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice4,
                LEAD(LineDiscount,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount4,
                LEAD(Quantity,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity4,
                LEAD(Start_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period4,
                LEAD(End_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period4,
                LEAD(specialization,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization4,

                LEAD(Artigo,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo5,
                LEAD(Descricao,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao5,
                LEAD(codiva,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva5,
                LEAD(UnitPrice,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice5,
                LEAD(LineDiscount,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount5,
                LEAD(Quantity,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity5,
                LEAD(Start_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period5,
                LEAD(End_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period5,
                LEAD(specialization,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization5,

                LEAD(Artigo,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo6,
                LEAD(Descricao,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao6,
                LEAD(codiva,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva6,
                LEAD(UnitPrice,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice6,
                LEAD(LineDiscount,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount6,
                LEAD(Quantity,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity6,
                LEAD(Start_date_period,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period6,
                LEAD(End_date_period,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period6,
                LEAD(specialization,5) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization6,
                
                LEAD(Artigo,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo7,
                LEAD(Descricao,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao7,
                LEAD(codiva,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva7,
                LEAD(UnitPrice,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice7,
                LEAD(LineDiscount,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount7,
                LEAD(Quantity,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity7,
                LEAD(Start_date_period,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period7,
                LEAD(End_date_period,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period7,
                LEAD(specialization,6) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization7,
                
                LEAD(Artigo,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo8,
                LEAD(Descricao,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao8,
                LEAD(codiva,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva8,
                LEAD(UnitPrice,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice8,
                LEAD(LineDiscount,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount8,
                LEAD(Quantity,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity8,
                LEAD(Start_date_period,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period8,
                LEAD(End_date_period,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period8,
                LEAD(specialization,7) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization8,
                
                LEAD(Artigo,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo9,
                LEAD(Descricao,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao9,
                LEAD(codiva,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva9,
                LEAD(UnitPrice,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice9,
                LEAD(LineDiscount,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount9,
                LEAD(Quantity,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity9,
                LEAD(Start_date_period,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period9,
                LEAD(End_date_period,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period9,
                LEAD(specialization,8) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization9,
                
                LEAD(Artigo,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo10,
                LEAD(Descricao,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao10,
                LEAD(codiva,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva10,
                LEAD(UnitPrice,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice10,
                LEAD(LineDiscount,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount10,
                LEAD(Quantity,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity10,
                LEAD(Start_date_period,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period10,
                LEAD(End_date_period,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period10,
                LEAD(specialization,9) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization10,
                
                LEAD(Artigo,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo11,
                LEAD(Descricao,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao11,
                LEAD(codiva,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva11,
                LEAD(UnitPrice,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice11,
                LEAD(LineDiscount,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount11,
                LEAD(Quantity,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity11,
                LEAD(Start_date_period,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period11,
                LEAD(End_date_period,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period11,
                LEAD(specialization,10) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization11,
                
                LEAD(Artigo,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Artigo12,
                LEAD(Descricao,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Descricao12,
                LEAD(codiva,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS codiva12,
                LEAD(UnitPrice,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS UnitPrice12,
                LEAD(LineDiscount,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS LineDiscount12,
                LEAD(Quantity,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Quantity12,
                LEAD(Start_date_period,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS Start_date_period12,
                LEAD(End_date_period,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS End_date_period12,
                LEAD(specialization,11) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS specialization12,

                ROW_NUMBER() OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_EasyPayID,batch_id ORDER BY v_main.invl_subid) AS ADDONSEQ
        FROM v_main
)
SELECT     
        inv.inv_center AS center,
        inv.inv_id AS id,
        inv.person_center || 'p' || inv.person_id AS "PERSONKEY",
        ------------ INVOICE MASTER -----------
        inv.TipoDoc,
        inv.Serie,
        inv.tipoentidade,
        TO_CHAR(inv.paymentDate,'YYYY-MM-DD' || ' 00:00:00') AS DataRes,
        inv.DescPag,
        inv.CondPag,
        inv.Moeda,
        inv.Cambio,
        inv.Referencia,
        inv.Empresa,
        inv.RefDocumentTipoDoc,
        inv.RefDocumentNumDoc,
        inv.RefDocumentSerie,
        inv.CDU_ExerpID,
        inv.CDU_ExerpTotalDocument,
        TO_CHAR(inv.DueDate,'YYYY-MM-DD HH24:MI:SS') AS DueDate,
        (CASE
                WHEN altnif.txtvalue IS NOT NULL THEN concat(cp.external_id,'|',altnif.txtvalue)
                ELSE concat(cp.external_id,'|',cp.national_id)
        END) AS Entidade,
        p.center AS CDU_ContactCenter,
        inv.CDU_EasyPayID,
        
        ------------ INVOICE DETAILS -----------
        inv.Artigo1,
        inv.Descricao1,
        inv.codiva1,
        inv.UnitPrice1 AS PrecUnit1,
        inv.LineDiscount1 AS Desconto1,
        inv.Quantity1 AS Quantidade1,
        NULL AS CDU_PaymentPeriod1,
        TO_CHAR(inv.Start_date_period1,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period1,
        TO_CHAR(inv.End_date_period1,'YYYY-MM-DD HH24:MI:SS') AS End_date_period1,
        inv.specialization1 AS CDU_Specialization1,
        
        inv.Artigo2,
        inv.Descricao2,
        inv.codiva2,
        inv.UnitPrice2 AS PrecUnit2,
        inv.LineDiscount2 AS Desconto2,
        inv.Quantity2 AS Quantidade2,
        NULL AS CDU_PaymentPeriod2,
        TO_CHAR(inv.Start_date_period2,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period2,
        TO_CHAR(inv.End_date_period2,'YYYY-MM-DD HH24:MI:SS') AS End_date_period2,
        inv.specialization2 AS CDU_Specialization2,
        
        inv.Artigo3,
        inv.Descricao3,
        inv.codiva3,
        inv.UnitPrice3 AS PrecUnit3,
        inv.LineDiscount3 AS Desconto3,
        inv.Quantity3 AS Quantidade3,
        NULL AS CDU_PaymentPeriod3,
        TO_CHAR(inv.Start_date_period3,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period3,
        TO_CHAR(inv.End_date_period3,'YYYY-MM-DD HH24:MI:SS') AS End_date_period3,
        inv.specialization3 AS CDU_Specialization3,
        
        inv.Artigo4,
        inv.Descricao4,
        inv.codiva4,
        inv.UnitPrice4 AS PrecUnit4,
        inv.LineDiscount4 AS Desconto4,
        inv.Quantity4 AS Quantidade4,
        NULL AS CDU_PaymentPeriod4,
        TO_CHAR(inv.Start_date_period4,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period4,
        TO_CHAR(inv.End_date_period4,'YYYY-MM-DD HH24:MI:SS') AS End_date_period4,
        inv.specialization4 AS CDU_Specialization4,
        
        inv.Artigo5,
        inv.Descricao5,
        inv.codiva5,
        inv.UnitPrice5 AS PrecUnit5,
        inv.LineDiscount5 AS Desconto5,
        inv.Quantity5 AS Quantidade5,
        NULL AS CDU_PaymentPeriod5,
        TO_CHAR(inv.Start_date_period5,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period5,
        TO_CHAR(inv.End_date_period5,'YYYY-MM-DD HH24:MI:SS') AS End_date_period5,
        inv.specialization5 AS CDU_Specialization5,
        
        inv.Artigo6,
        inv.Descricao6,
        inv.codiva6,
        inv.UnitPrice6 AS PrecUnit6,
        inv.LineDiscount6 AS Desconto6,
        inv.Quantity6 AS Quantidade6,
        NULL AS CDU_PaymentPeriod6,
        TO_CHAR(inv.Start_date_period6,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period6,
        TO_CHAR(inv.End_date_period6,'YYYY-MM-DD HH24:MI:SS') AS End_date_period6,
        inv.specialization6 AS CDU_Specialization6,
        
        inv.Artigo7,
        inv.Descricao7,
        inv.codiva7,
        inv.UnitPrice7 AS PrecUnit7,
        inv.LineDiscount7 AS Desconto7,
        inv.Quantity7 AS Quantidade7,
        NULL AS CDU_PaymentPeriod7,
        TO_CHAR(inv.Start_date_period7,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period7,
        TO_CHAR(inv.End_date_period7,'YYYY-MM-DD HH24:MI:SS') AS End_date_period7,
        inv.specialization7 AS CDU_Specialization7,
        
        inv.Artigo8,
        inv.Descricao8,
        inv.codiva8,
        inv.UnitPrice8 AS PrecUnit8,
        inv.LineDiscount8 AS Desconto8,
        inv.Quantity8 AS Quantidade8,
        NULL AS CDU_PaymentPeriod8,
        TO_CHAR(inv.Start_date_period8,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period8,
        TO_CHAR(inv.End_date_period8,'YYYY-MM-DD HH24:MI:SS') AS End_date_period8,
        inv.specialization8 AS CDU_Specialization8,
        
        inv.Artigo9,
        inv.Descricao9,
        inv.codiva9,
        inv.UnitPrice9 AS PrecUnit9,
        inv.LineDiscount9 AS Desconto9,
        inv.Quantity9 AS Quantidade9,
        NULL AS CDU_PaymentPeriod9,
        TO_CHAR(inv.Start_date_period9,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period9,
        TO_CHAR(inv.End_date_period9,'YYYY-MM-DD HH24:MI:SS') AS End_date_period9,
        inv.specialization9 AS CDU_Specialization9,
        
        inv.Artigo10,
        inv.Descricao10,
        inv.codiva10,
        inv.UnitPrice10 AS PrecUnit10,
        inv.LineDiscount10 AS Desconto10,
        inv.Quantity10 AS Quantidade10,
        NULL AS CDU_PaymentPeriod10,
        TO_CHAR(inv.Start_date_period10,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period10,
        TO_CHAR(inv.End_date_period10,'YYYY-MM-DD HH24:MI:SS') AS End_date_period10,
        inv.specialization10 AS CDU_Specialization10,
        
        inv.Artigo11,
        inv.Descricao11,
        inv.codiva11,
        inv.UnitPrice11 AS PrecUnit11,
        inv.LineDiscount11 AS Desconto11,
        inv.Quantity11 AS Quantidade11,
        NULL AS CDU_PaymentPeriod11,
        TO_CHAR(inv.Start_date_period11,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period11,
        TO_CHAR(inv.End_date_period11,'YYYY-MM-DD HH24:MI:SS') AS End_date_period11,
        inv.specialization11 AS CDU_Specialization11,
        
        inv.Artigo12,
        inv.Descricao12,
        inv.codiva12,
        inv.UnitPrice12 AS PrecUnit12,
        inv.LineDiscount12 AS Desconto12,
        inv.Quantity12 AS Quantidade12,
        NULL AS CDU_PaymentPeriod12,
        TO_CHAR(inv.Start_date_period12,'YYYY-MM-DD HH24:MI:SS') AS Start_date_period12,
        TO_CHAR(inv.End_date_period12,'YYYY-MM-DD HH24:MI:SS') AS End_date_period12,
        inv.specialization12 AS CDU_Specialization12,
        ------------- EXTRA DETAILS ------------
        
        inv.batch_id
FROM
(
        SELECT
                ------------ INVOICE MASTER -----------
                CAST('FAE' AS TEXT) AS TipoDoc,
                v_pivot.Serie,
                CAST('C' AS TEXT) AS tipoentidade, -- C for Customers
                v_pivot.paymentDate,
                0 AS DescPag,
                CAST('1' AS TEXT) AS CondPag,
                CAST('EUR' AS TEXT) AS Moeda,
                CAST('1' AS TEXT) AS Cambio,
                v_pivot.inv_center || 'inv' || v_pivot.inv_id AS Referencia,
                CAST('Fitness' AS TEXT) AS Empresa,
                NULL AS RefDocumentTipoDoc, -- Only for CREDITNOTES
                NULL AS RefDocumentNumDoc, -- Only for CREDITNOTES
                NULL AS RefDocumentSerie, -- Only for CREDITNOTES
                v_pivot.CDU_ExerpID,
                v_pivot.CDU_ExerpTotalDocument,
                v_pivot.DueDate,
                
                ------------ INVOICE DETAILS -----------
                v_pivot.Artigo AS Artigo1,
                v_pivot.Descricao AS Descricao1,
                v_pivot.codiva AS codiva1,
                v_pivot.UnitPrice AS UnitPrice1,
                v_pivot.LineDiscount AS LineDiscount1,
                v_pivot.Quantity AS Quantity1,
                v_pivot.Start_date_period AS Start_date_period1,
                v_pivot.End_date_period AS End_date_period1,
                v_pivot.specialization AS specialization1,
                
                v_pivot.Artigo2,
                v_pivot.Descricao2,
                v_pivot.codiva2,
                v_pivot.UnitPrice2,
                v_pivot.LineDiscount2,
                v_pivot.Quantity2,
                v_pivot.Start_date_period2,
                v_pivot.End_date_period2,
                v_pivot.specialization2,
                
                v_pivot.Artigo3,
                v_pivot.Descricao3,
                v_pivot.codiva3,
                v_pivot.UnitPrice3,
                v_pivot.LineDiscount3,
                v_pivot.Quantity3,
                v_pivot.Start_date_period3,
                v_pivot.End_date_period3,
                v_pivot.specialization3,
                
                v_pivot.Artigo4,
                v_pivot.Descricao4,
                v_pivot.codiva4,
                v_pivot.UnitPrice4,
                v_pivot.LineDiscount4,
                v_pivot.Quantity4,
                v_pivot.Start_date_period4,
                v_pivot.End_date_period4,
                v_pivot.specialization4,
                
                v_pivot.Artigo5,
                v_pivot.Descricao5,
                v_pivot.codiva5,
                v_pivot.UnitPrice5,
                v_pivot.LineDiscount5,
                v_pivot.Quantity5,
                v_pivot.Start_date_period5,
                v_pivot.End_date_period5,
                v_pivot.specialization5,
                
                v_pivot.Artigo6,
                v_pivot.Descricao6,
                v_pivot.codiva6,
                v_pivot.UnitPrice6,
                v_pivot.LineDiscount6,
                v_pivot.Quantity6,
                v_pivot.Start_date_period6,
                v_pivot.End_date_period6,
                v_pivot.specialization6,
                
                v_pivot.Artigo7,
                v_pivot.Descricao7,
                v_pivot.codiva7,
                v_pivot.UnitPrice7,
                v_pivot.LineDiscount7,
                v_pivot.Quantity7,
                v_pivot.Start_date_period7,
                v_pivot.End_date_period7,
                v_pivot.specialization7,
                
                v_pivot.Artigo8,
                v_pivot.Descricao8,
                v_pivot.codiva8,
                v_pivot.UnitPrice8,
                v_pivot.LineDiscount8,
                v_pivot.Quantity8,
                v_pivot.Start_date_period8,
                v_pivot.End_date_period8,
                v_pivot.specialization8,
                
                v_pivot.Artigo9,
                v_pivot.Descricao9,
                v_pivot.codiva9,
                v_pivot.UnitPrice9,
                v_pivot.LineDiscount9,
                v_pivot.Quantity9,
                v_pivot.Start_date_period9,
                v_pivot.End_date_period9,
                v_pivot.specialization9,
                
                v_pivot.Artigo10,
                v_pivot.Descricao10,
                v_pivot.codiva10,
                v_pivot.UnitPrice10,
                v_pivot.LineDiscount10,
                v_pivot.Quantity10,
                v_pivot.Start_date_period10,
                v_pivot.End_date_period10,
                v_pivot.specialization10,
                
                v_pivot.Artigo11,
                v_pivot.Descricao11,
                v_pivot.codiva11,
                v_pivot.UnitPrice11,
                v_pivot.LineDiscount11,
                v_pivot.Quantity11,
                v_pivot.Start_date_period11,
                v_pivot.End_date_period11,
                v_pivot.specialization11,
                
                v_pivot.Artigo12,
                v_pivot.Descricao12,
                v_pivot.codiva12,
                v_pivot.UnitPrice12,
                v_pivot.LineDiscount12,
                v_pivot.Quantity12,
                v_pivot.Start_date_period12,
                v_pivot.End_date_period12,
                v_pivot.specialization12,
                ------------- EXTRA DETAILS ------------
                v_pivot.person_center,
                v_pivot.person_id,
                v_pivot.inv_center,
                v_pivot.inv_id,
                v_pivot.CDU_EasyPayID,
                v_pivot.batch_id
        FROM
                v_pivot
        WHERE
                ADDONSEQ=1
) inv
JOIN vivagym.persons p 
        ON p.center = inv.person_center AND p.id = inv.person_id
JOIN vivagym.persons cp
        ON p.current_person_center = cp.center AND p.current_person_id = cp.id
LEFT JOIN vivagym.person_ext_attrs altnif
        ON cp.center = altnif.personcenter AND cp.id = altnif.personid AND altnif.name = 'AALTNIFNBR'
ORDER BY 7
        