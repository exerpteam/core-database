-- The extract is extracted from Exerp on 2026-02-08
-- my test version of the extract with ID 15003
WITH params AS MATERIALIZED
(
   SELECT
    TO_CHAR(current_timestamp, 'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
    CAST(dateToLongC('2025-11-01', c.id) AS BIGINT) AS fromDate,
    CAST(dateToLongC('2025-12-01', c.id) AS BIGINT) AS toDate,
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
                longToDateC(cn.entry_time, cn.center) AS paymentDate,
                cn.center || 'cred' || cn.id AS Referencia,
                cn.fiscal_export_token AS CDU_ExerpID,
                SUM(cnl.total_amount) over (partition BY cnl.CENTER,cnl.ID) AS CDU_ExerpTotalDocument,
                longToDateC(cn.trans_time, cn.center) AS DueDate,
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
                NULL AS Start_date_period,
                NULL AS End_date_period,
                NULL AS specialization,
                null AS CDU_EasyPayID, --captureID from EasyPay
                par.batch_id,
                i.center || 'inv' || i.id AS OriginalDocumentReference,
                NULL AS OriginalDocumentExerpID,
                cnl.subid AS cnl_subid
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
        LEFT JOIN vivagym.invoice_lines_mt il
                ON cnl.invoiceline_center = il.center
                AND cnl.invoiceline_id = il.id
                AND cnl.invoiceline_subid = il.subid
        LEFT JOIN vivagym.invoices i
                ON il.center = i.center
                AND il.id = i.id
        WHERE
                -- anadir condicion from and to respecto a una columna de tiempo
                payer.SEX != 'C'
                AND cnl.net_amount != '0'
                AND art.center IS NULL
                AND cn.entry_time between par.fromDate AND par.toDate
        UNION ALL
        --- ACCOUNTS ---
        SELECT
                ------------------------ INVOICE MASTER ------------------------
                t1.serie,
                t1.paymentDate,
                t1.Referencia,
                t1.CDU_ExerpID,
                t1.CDU_ExerpTotalDocument,
                t1.DueDate,
                t1.person_center,
                t1.person_id,
                t1.cn_center,
                t1.cn_id,
                ------------------------ INVOICE DETAILS ------------------------
                prod.external_id AS Artigo,
                cnl.text AS Descricao,
                (CASE
                        WHEN cnvt.rate IS NOT NULL THEN CAST(cnvt.rate*100 AS INT)
                        ELSE '0'
                END) AS codiva,
                ROUND(cnl.total_amount,2) AS UnitPrice,
                t1.LineDiscount,
                cnl.quantity AS Quantity,
                t1.Start_date_period,
                t1.End_date_period,
                t1.specialization,
                t1.CDU_EasyPayID,
                t1.batch_id,
                t1.OriginalDocumentReference,
                t1.OriginalDocumentExerpID,
                cnl.subid AS cnl_subid
        FROM
        (
                SELECT
                        ------------------------ INVOICE MASTER ------------------------
                        CAST(extract(YEAR FROM longToDateC(artm.entry_time, cn.center)) AS TEXT) || 'P' AS serie,
                        longToDateC(artm.entry_time, cn.center) AS paymentDate,
                        cn.center || 'cred' || cn.id AS Referencia,
                        cn.fiscal_export_token AS CDU_ExerpID,
                        artm.amount AS CDU_ExerpTotalDocument,
                        COALESCE(art.due_date, longToDateC(cn.trans_time, cn.center)) AS DueDate,
                        payer.center AS person_center,
                        payer.id AS person_id,
                        cn.center AS cn_center,
                        cn.id AS cn_id,
                        ------------------------ INVOICE DETAILS ------------------------
                        NULL AS Start_date_period,
                        NULL AS End_date_period,
                        NULL AS specialization,
                        null AS CDU_EasyPayID,
                        0 AS LineDiscount,
                        par.batch_id,
                        (CASE WHEN art2.ref_type = 'INVOICE' THEN art2.ref_center || 'inv' || art2.ref_id ELSE NULL END) AS OriginalDocumentReference,
                        NULL AS OriginalDocumentExerpID
                FROM vivagym.credit_notes cn
                JOIN params par
                        ON par.center_id = cn.center
                JOIN vivagym.ar_trans art
                        ON art.ref_center = cn.center AND art.ref_id = cn.id AND art.ref_type = 'CREDIT_NOTE'
                JOIN vivagym.art_match artm 
                        ON art.center = artm.art_paying_center AND art.id = artm.art_paying_id AND art.subid = artm.art_paying_subid
                JOIN vivagym.persons payer
                        ON payer.center = cn.payer_center AND payer.id = cn.payer_id
                JOIN vivagym.ar_trans art2 
                        ON art2.center = artm.art_paid_center AND art2.id = artm.art_paid_id AND art2.subid = artm.art_paid_subid
                WHERE
                        payer.sex != 'C'
                        AND artm.entry_time between par.fromDate AND par.toDate
                        AND art.amount != 0
        ) t1
        JOIN vivagym.credit_note_lines_mt cnl
                ON cnl.center = t1.cn_center AND cnl.id = t1.cn_id 
        JOIN vivagym.products prod
                ON prod.center = cnl.productcenter AND prod.id = cnl.productid
        LEFT JOIN vivagym.credit_note_line_vat_at_link cnvt
                ON cnvt.credit_note_line_center = cnl.center AND cnvt.credit_note_line_id = cnl.id AND cnvt.credit_note_line_subid = cnl.subid
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(Artigo,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Artigo2,
                LEAD(Descricao,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Descricao2,
                LEAD(codiva,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS codiva2,
                LEAD(UnitPrice,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS UnitPrice2,
                LEAD(LineDiscount,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS LineDiscount2,
                LEAD(Quantity,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Quantity2,
                LEAD(Start_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Start_date_period2,
                LEAD(End_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS End_date_period2,
                LEAD(specialization,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS specialization2,
                
                LEAD(Artigo,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Artigo3,
                LEAD(Descricao,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Descricao3,
                LEAD(codiva,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS codiva3,
                LEAD(UnitPrice,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS UnitPrice3,
                LEAD(LineDiscount,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS LineDiscount3,
                LEAD(Quantity,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Quantity3,
                LEAD(Start_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Start_date_period3,
                LEAD(End_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS End_date_period3,
                LEAD(specialization,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS specialization3,

                LEAD(Artigo,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Artigo4,
                LEAD(Descricao,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Descricao4,
                LEAD(codiva,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS codiva4,
                LEAD(UnitPrice,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS UnitPrice4,
                LEAD(LineDiscount,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS LineDiscount4,
                LEAD(Quantity,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Quantity4,
                LEAD(Start_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Start_date_period4,
                LEAD(End_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS End_date_period4,
                LEAD(specialization,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS specialization4,

                LEAD(Artigo,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Artigo5,
                LEAD(Descricao,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Descricao5,
                LEAD(codiva,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS codiva5,
                LEAD(UnitPrice,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS UnitPrice5,
                LEAD(LineDiscount,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS LineDiscount5,
                LEAD(Quantity,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Quantity5,
                LEAD(Start_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS Start_date_period5,
                LEAD(End_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS End_date_period5,
                LEAD(specialization,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS specialization5,

                ROW_NUMBER() OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,cn_center,cn_id,CDU_EasyPayID,OriginalDocumentReference,OriginalDocumentExerpID,batch_id ORDER BY v_main.cnl_subid) AS ADDONSEQ
        FROM v_main
)
SELECT     
        cred.cn_center AS center,
        cred.cn_id AS id,
        cred.person_center || 'p' || cred.person_id AS "PERSONKEY",
        ------------ INVOICE MASTER -----------
        cred.TipoDoc,
        cred.Serie,
        cred.tipoentidade,
        TO_CHAR(cred.paymentDate,'YYYY-MM-DD') || ' 00:00:00' AS DataRes,
        cred.DescPag,
        cred.CondPag,
        cred.Moeda,
        cred.Cambio,
        cred.Referencia,
        cred.Empresa,
        cred.OriginalDocumentReference,
        cred.OriginalDocumentExerpID,
        cred.CDU_ExerpID,
        cred.CDU_ExerpTotalDocument,
        TO_CHAR(cred.DueDate,'YYYY-MM-DD HH24:MI:SS') AS DueDate,
        (CASE
                WHEN altnif.txtvalue IS NOT NULL THEN concat(cp.external_id,'|',altnif.txtvalue)
                ELSE concat(cp.external_id,'|',cp.national_id)
        END) AS Entidade,
        p.center AS CDU_ContactCenter,
        cred.CDU_EasyPayID,
        ------------ INVOICE DETAILS -----------
        cred.Artigo1,
        cred.Descricao1,
        cred.codiva1,
        cred.UnitPrice1 AS PrecUnit1,
        cred.LineDiscount1 AS Desconto1,
        cred.Quantity1 AS Quantidade1,
        NULL AS CDU_PaymentPeriod1,
        NULL AS Start_date_period1,
        NULL AS End_date_period1,
        cred.specialization1 AS CDU_Specialization1,
        
        cred.Artigo2,
        cred.Descricao2,
        cred.codiva2,
        cred.UnitPrice2 AS PrecUnit2,
        cred.LineDiscount2 AS Desconto2,
        cred.Quantity2 AS Quantidade2,
        NULL AS CDU_PaymentPeriod2,
        NULL AS Start_date_period2,
        NULL AS End_date_period2,
        cred.specialization2 AS CDU_Specialization2,
        
        cred.Artigo3,
        cred.Descricao3,
        cred.codiva3,
        cred.UnitPrice3 AS PrecUnit3,
        cred.LineDiscount3 AS Desconto3,
        cred.Quantity3 AS Quantidade3,
        NULL AS CDU_PaymentPeriod3,
        NULL AS Start_date_period3,
        NULL AS End_date_period3,
        cred.specialization3 AS CDU_Specialization3,
        
        cred.Artigo4,
        cred.Descricao4,
        cred.codiva4,
        cred.UnitPrice4 AS PrecUnit4,
        cred.LineDiscount4 AS Desconto4,
        cred.Quantity4 AS Quantidade4,
        NULL AS CDU_PaymentPeriod4,
        NULL AS Start_date_period4,
        NULL AS End_date_period4,
        cred.specialization4 AS CDU_Specialization4,
        
        cred.Artigo5,
        cred.Descricao5,
        cred.codiva5,
        cred.UnitPrice5 AS PrecUnit5,
        cred.LineDiscount5 AS Desconto5,
        cred.Quantity5 AS Quantidade5,
        NULL AS CDU_PaymentPeriod5,
        NULL AS Start_date_period5,
        NULL AS End_date_period5,
        cred.specialization5 AS CDU_Specialization5,
        
        ------------- EXTRA DETAILS ------------
        cred.batch_id
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
) cred
LEFT JOIN vivagym.persons p 
        ON p.center = cred.person_center AND p.id = cred.person_id
LEFT JOIN vivagym.persons cp
        ON p.current_person_center = cp.center AND p.current_person_id = cp.id
LEFT JOIN vivagym.person_ext_attrs altnif
        ON cp.center = altnif.personcenter AND cp.id = altnif.personid AND altnif.name = 'AALTNIFNBR'
ORDER BY 7