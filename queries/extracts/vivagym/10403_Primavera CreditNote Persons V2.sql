SELECT
        r1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todays_date,
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
                        CAST(extract(YEAR FROM longToDateC(cn.entry_time, cn.center)) AS TEXT) || 'U'  AS serie,
                        longToDateC(cn.entry_time, cn.center) AS paymentDate, -- THEY ARE PAID AUTOMATICALLY
                        cnl.center || 'cred' || cnl.ID AS Referencia,
                        cn.fiscal_export_token AS CDU_ExerpID,
                        SUM(cnl.total_amount) over (partition BY cnl.CENTER,cnl.ID) AS CDU_ExerpTotalDocument,
                        longToDateC(cn.trans_time, cn.center) AS DueDate, -- NO DUE DATE FOR TRANSACTIONS THAT DO NOT REACH THE PAYMENT ACCOUNT
                        payer.center AS person_center,
                        payer.id AS person_id,
                        cnl.center AS cn_center,
                        cnl.id AS cn_id,
                        ------------------------ INVOICE DETAILS ------------------------
                        prod.external_id AS Artigo,
                        cnl.text AS Descricao,
                        (CASE
                                WHEN cnvt.rate IS NOT NULL THEN CAST(cnvt.rate*100 AS INT)
                                ELSE '0'
                        END) AS codiva,
                        ROUND(cnl.total_amount,2) AS UnitPrice,
                        0 AS LineDiscount,
                        cnl.quantity AS Quantity,
                        COALESCE(spp.from_date,longToDateC(cn.trans_time, cn.center)) AS Start_date_period,
                        COALESCE(spp.to_date,longToDateC(cn.trans_time, cn.center)) AS End_date_period,
                        (CASE
                                WHEN spp.from_date IS NOT NULL THEN 'true'
                                ELSE 'false' 
                        END) AS specialization,
                        cnl.subid,
                        null AS CDU_EasyPayID, --captureID from EasyPay
                        par.batch_id,
                        i.center || 'inv' || i.id AS OriginalDocumentReference,
                        i.fiscal_export_token AS OriginalDocumentExerpID
                FROM vivagym.credit_note_lines_mt cnl
                JOIN params par
                        ON par.center_id = cnl.center
                JOIN vivagym.credit_notes cn
                        ON cnl.center = cn.center
                        AND cnl.id = cn.id
                JOIN vivagym.products prod
                        ON prod.center = cnl.productcenter
                        AND prod.id = cnl.productid
                LEFT JOIN vivagym.ar_trans art
                        ON art.ref_center = cn.center
                        AND art.ref_id = cn.id
                        AND art.ref_type = 'CREDIT_NOTE'
                LEFT JOIN vivagym.product_group pg
                        ON pg.ID = prod.primary_product_group_id
                LEFT JOIN vivagym.persons p
                        ON p.center = cnl.person_center
                        AND p.id = cnl.person_id
                LEFT JOIN vivagym.persons payer
                        ON payer.center = cn.payer_center
                        AND payer.id = cn.payer_id
                LEFT JOIN vivagym.credit_note_line_vat_at_link cnvt
                        ON cnvt.credit_note_line_center = cnl.center
                        AND cnvt.credit_note_line_id = cnl.id
                        AND cnvt.credit_note_line_subid = cnl.subid
                LEFT JOIN vivagym.cashregistertransactions crt
                        ON crt.paysessionid = cn.paysessionid
                LEFT JOIN vivagym.invoice_lines_mt il
                        ON cnl.invoiceline_center = il.center
                        AND cnl.invoiceline_id = il.id
                        AND cnl.invoiceline_subid = il.subid
                LEFT JOIN vivagym.invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                LEFT JOIN vivagym.spp_invoicelines_link spl
                        ON spl.invoiceline_center = il.center
                        AND spl.invoiceline_id = il.id
                        AND spl.invoiceline_subid = il.subid
                LEFT JOIN vivagym.subscriptionperiodparts spp
                        ON spl.period_center = spp.center
                        AND spl.period_id = spp.id
                        AND spl.period_subid = spp.subid
                WHERE
                        -- anadir condicion from and to respecto a una columna de tiempo
                        payer.SEX != 'C'
                        AND cnl.net_amount != '0'
                        AND art.center IS NULL
                        AND cn.center IN (:center) 
                        AND (cn.fiscal_reference IS NULL OR cn.fiscal_reference = 'REVOKED')
                        AND cn.entry_time between par.fromDate AND par.toDate
                        /*AND
                        (
                                i.center IS NULL
                                OR
                                (i.center IS NOT NULL AND i.fiscal_reference IS NOT NULL)
                        )*/
                UNION ALL
                --- ACCOUNTS ---
                SELECT
                        ------------------------ INVOICE MASTER ------------------------
                        CAST(extract(YEAR FROM longToDateC(cn.entry_time, cn.center)) AS TEXT) || 'P' AS serie,
                        longToDateC(cn.entry_time, cn.center) AS paymentDate, -- THIS IS NOT 100% CORRECT AS THIS IS WHEN THE SETTLEMENT HAPPENS (PROBABLY ONE DAY BEFORE PAYMENT WAS DONE)
                        cnl.center || 'cred' || cnl.id AS Referencia,
                        cn.fiscal_export_token AS CDU_ExerpID,
                        SUM(cnl.total_amount) over (partition BY cnl.CENTER,cnl.ID) AS CDU_ExerpTotalDocument,
                        COALESCE(art.due_date, longToDateC(cn.trans_time, cn.center)) AS DueDate, -- NOT ALL TRANSATIONS WILL HAVE DUEDATE. THOSE THAT DO NOT MAKE IT INTO A PAYMENT REQUEST WILL NOT.
                        payer.center AS person_center,
                        payer.id AS person_id,
                        cnl.center AS inv_center,
                        cnl.id AS inv_id,
                        ------------------------ INVOICE DETAILS ------------------------
                        prod.external_id AS Artigo,
                        cnl.text AS Descricao,
                        (CASE
                                WHEN cnvt.rate IS NOT NULL THEN CAST(cnvt.rate*100 AS INT)
                                ELSE '0'
                        END) AS codiva,
                        ROUND(cnl.total_amount,2) AS UnitPrice,
                        0 AS LineDiscount,
                        cnl.quantity AS Quantity,
                        COALESCE(spp.from_date, longToDateC(cn.trans_time, cn.center)) AS Start_date_period,
                        COALESCE(spp.to_date, longToDateC(cn.trans_time, cn.center)) AS End_date_period,
                        (CASE
                                WHEN spp.from_date IS NOT NULL THEN 'true'
                                ELSE 'false' 
                        END) AS specialization,
                        cnl.subid,
                        null AS CDU_EasyPayID,
                        par.batch_id,
                        i.center || 'inv' || i.id AS OriginalDocumentReference,
                        i.fiscal_export_token AS OriginalDocumentExerpID
                FROM vivagym.credit_note_lines_mt cnl
                JOIN params par
                        ON par.center_id = cnl.center
                JOIN vivagym.credit_notes cn
                        ON cnl.center = cn.center
                        AND cnl.id = cn.id
                JOIN vivagym.products prod
                        ON prod.center = cnl.productcenter
                        AND prod.id = cnl.productid
                JOIN vivagym.ar_trans art
                        ON art.ref_center = cn.center
                        AND art.ref_id = cn.id
                        AND art.ref_type = 'CREDIT_NOTE'
                LEFT JOIN vivagym.product_group pg
                        ON pg.ID = prod.primary_product_group_id
                LEFT JOIN vivagym.persons p
                        ON p.center = cnl.person_center
                        AND p.id = cnl.person_id
                LEFT JOIN vivagym.cashregisters crg
                        ON crg.center = cn.cashregister_center
                        AND crg.id = cn.cashregister_id
                LEFT JOIN vivagym.persons payer
                        ON payer.center = cn.payer_center
                        AND payer.id = cn.payer_id
                LEFT JOIN vivagym.credit_note_line_vat_at_link cnvt
                        ON cnvt.credit_note_line_center = cnl.center
                        AND cnvt.credit_note_line_id = cnl.id
                        AND cnvt.credit_note_line_subid = cnl.subid
                LEFT JOIN invoice_lines_mt il
                        ON cnl.invoiceline_center = il.center
                        AND cnl.invoiceline_id = il.id
                        AND cnl.invoiceline_subid = il.subid
                LEFT JOIN vivagym.invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                LEFT JOIN vivagym.spp_invoicelines_link spl
                        ON spl.invoiceline_center = il.center
                        AND spl.invoiceline_id = il.id
                        AND spl.invoiceline_subid = il.subid
                LEFT JOIN vivagym.subscriptionperiodparts spp
                        ON spl.period_center = spp.center
                        AND spl.period_id = spp.id
                        AND spl.period_subid = spp.subid
                LEFT JOIN vivagym.ar_trans arti
                        ON arti.ref_center = i.center
                        AND arti.ref_id = i.id
                        AND arti.ref_type = 'INVOICE'
                WHERE
                        payer.SEX != 'C'
                        AND cnl.center IN (:center) 
                        AND (cn.fiscal_reference IS NULL OR cn.fiscal_reference = 'REVOKED')
                        AND cnl.net_amount != 0
                        --AND art.STATUS = 'CLOSED' 
                        --AND art.unsettled_amount = 0
                        AND cn.entry_time between par.fromDate AND par.toDate
                        /*AND
                        (
                                arti.center IS NULL -- settled with a stand alone invoice (transfer)
                                OR
                                arti.unsettled_amount = 0
                        )*/
                        /*AND
                        (
                                i.center IS NULL
                                OR
                                (i.center IS NOT NULL AND i.fiscal_reference IS NOT NULL)
                                OR
                                i.text = 'Converted subscription invoice'
                        )*/
        ),
        v_pivot AS
        (
                SELECT
                        v_main.*,
                        LEAD(Artigo,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo2,
                        LEAD(Descricao,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao2,
                        LEAD(codiva,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva2,
                        LEAD(UnitPrice,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice2,
                        LEAD(LineDiscount,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount2,
                        LEAD(Quantity,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity2,
                        LEAD(Start_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period2,
                        LEAD(End_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period2,
                        LEAD(specialization,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization2,
                        
                        LEAD(Artigo,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo3,
                        LEAD(Descricao,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao3,
                        LEAD(codiva,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva3,
                        LEAD(UnitPrice,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice3,
                        LEAD(LineDiscount,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount3,
                        LEAD(Quantity,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity3,
                        LEAD(Start_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period3,
                        LEAD(End_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period3,
                        LEAD(specialization,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization3,
                        
                        LEAD(Artigo,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo4,
                        LEAD(Descricao,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao4,
                        LEAD(codiva,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva4,
                        LEAD(UnitPrice,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice4,
                        LEAD(LineDiscount,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount4,
                        LEAD(Quantity,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity4,
                        LEAD(Start_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period4,
                        LEAD(End_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period4,
                        LEAD(specialization,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization4,
                        
                        LEAD(Artigo,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo5,
                        LEAD(Descricao,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao5,
                        LEAD(codiva,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva5,
                        LEAD(UnitPrice,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice5,
                        LEAD(LineDiscount,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount5,
                        LEAD(Quantity,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity5,
                        LEAD(Start_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period5,
                        LEAD(End_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period5,
                        LEAD(specialization,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization5,
                          
                        ROW_NUMBER() OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS ADDONSEQ
                FROM v_main
        )
        SELECT     
                inv.cn_center AS center,
                inv.cn_id AS id,
                inv.person_center || 'p' || inv.person_id AS "PERSONKEY",
                ------------ INVOICE MASTER -----------
                inv.TipoDoc,
                inv.Serie,
                inv.tipoentidade,
                TO_CHAR(inv.paymentDate,'YYYY-MM-DD') || ' 00:00:00' AS DataRes,
                inv.DescPag,
                inv.CondPag,
                inv.Moeda,
                inv.Cambio,
                inv.Referencia,
                inv.Empresa,
                inv.OriginalDocumentReference,
                inv.OriginalDocumentExerpID,
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
                
                ------------- EXTRA DETAILS ------------
                
                inv.batch_id
        FROM
        (
                SELECT
                        ------------ INVOICE MASTER -----------
                        CAST('NCE' AS TEXT) AS TipoDoc,
                        v_pivot.Serie,
                        CAST('C' AS TEXT) AS tipoentidade, -- C for Customers
                        v_pivot.paymentDate,
                        0 AS DescPag,
                        CAST('1' AS TEXT) AS CondPag,
                        CAST('EUR' AS TEXT) AS Moeda,
                        CAST('1' AS TEXT) AS Cambio,
                        v_pivot.cn_center || 'cred' || v_pivot.cn_id AS Referencia,
                        CAST('Fitness' AS TEXT) AS Empresa,
                        v_pivot.OriginalDocumentReference, -- Only for CREDITNOTES
                        v_pivot.OriginalDocumentExerpID, -- Only for CREDITNOTES
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
                        
                        ------------- EXTRA DETAILS ------------
                        v_pivot.person_center,
                        v_pivot.person_id,
                        v_pivot.cn_center,
                        v_pivot.cn_id,
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
) r1