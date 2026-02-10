-- The extract is extracted from Exerp on 2026-02-08
-- Specific list of invoices
SELECT
        r1.*
FROM
(
        WITH params AS MATERIALIZED
        (
                SELECT
                        TO_CHAR(current_timestamp,'YYYY-MM-DD HH24:MI:SS.MS') AS batch_id,
                        --dateToLongC(getCenterTime(c.id),c.id) - (2*24*60*60*1000) AS cutdate, -- 2 days
                        c.id AS center_id
                FROM
                        CENTERS c
                WHERE
                        c.country = 'PT'
        ),
        settlement AS MATERIALIZED
        (
                -- check if the query is faster if I start from Invoices and get rid of those that have a fiscal_reference
                        SELECT
                                s1.center,
                                s1.id,
                                s1.subid,
                                s1.latest_settlement
                        FROM
                        (
                                SELECT
                                        art.center,
                                        art.id,
                                        art.subid,
                                        art.amount,
                                        max(artm.entry_time) AS latest_settlement,
                                        sum(artm.amount) AS total_amount_settled
                                FROM vivagym.ar_trans art
                                JOIN params par
                                        ON par.center_id = art.center
                                JOIN vivagym.art_match artm 
                                        ON artm.art_paid_center = art.center
                                        AND artm.art_paid_id = art.id
                                        AND artm.art_paid_subid = art.subid
                                WHERE   
                                        art.ref_type = 'INVOICE'
                                        AND artm.cancelled_time IS NULL
                                GROUP BY
                                        art.center,
                                        art.id,
                                        art.subid
                        ) s1
                        WHERE s1.amount = -(s1.total_amount_settled)
        ),
        v_main AS
        (
                -- NO PAYMENT ACCOUNT
                SELECT  
                        ------------------------ INVOICE MASTER ------------------------
                        CAST(extract(YEAR FROM longToDateC(i.entry_time, i.center)) AS TEXT) || 'U' AS serie,
                        longToDateC(i.trans_time, i.center) AS paymentDate, -- THEY ARE PAID AUTOMATICALLY
                        il.center || 'inv' || il.id AS Referencia,
                        i.fiscal_export_token AS CDU_ExerpID,
                        SUM(il.total_amount) over (partition BY il.CENTER,il.ID) AS CDU_ExerpTotalDocument,
                        longToDateC(i.trans_time, i.center) AS DueDate, -- NO DUE DATE FOR TRANSACTIONS THAT DO NOT REACH THE PAYMENT ACCOUNT
                        payer.center AS person_center,
                        payer.id AS person_id,
                        il.center AS inv_center,
                        il.id AS inv_id,
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
                        il.subid,
                        crt.coment AS CDU_EasyPayID, --captureID from EasyPay
                        par.batch_id
                FROM invoice_lines_mt il
                JOIN params par
                        ON par.center_id = il.center
                JOIN vivagym.invoices i
                        ON il.center = i.center
                        AND il.id = i.id
                JOIN vivagym.products prod
                        ON prod.center = il.productcenter
                        AND prod.id = il.productid
                LEFT JOIN vivagym.ar_trans art
                        ON art.ref_center = i.center
                        AND art.ref_id = i.id
                        AND art.ref_type = 'INVOICE'
                LEFT JOIN vivagym.spp_invoicelines_link spl
                        ON spl.invoiceline_center = il.center
                        AND spl.invoiceline_id = il.id
                        AND spl.invoiceline_subid = il.subid
                LEFT JOIN vivagym.subscriptionperiodparts spp
                        ON spl.period_center = spp.center
                        AND spl.period_id = spp.id
                        AND spl.period_subid = spp.subid
                LEFT JOIN vivagym.product_group pg
                        ON pg.ID = prod.primary_product_group_id
                LEFT JOIN vivagym.persons p
                        ON p.center = il.person_center
                        AND p.id = il.person_id
                LEFT JOIN vivagym.persons payer
                        ON payer.center = i.payer_center
                        AND payer.id = i.payer_id
                LEFT JOIN vivagym.invoicelines_vat_at_link ilvt
                        ON ilvt.invoiceline_center = il.center
                        AND ilvt.invoiceline_id = il.id
                        AND ilvt.invoiceline_subid = il.subid
                LEFT JOIN vivagym.cashregistertransactions crt
                        ON crt.paysessionid = i.paysessionid
                WHERE
                        i.center || 'inv' || i.id in
                         ('710inv46396',
'710inv46401',
'710inv46410',
'710inv46431',
'710inv46449',
'710inv46472',
'710inv46487',
'710inv46502',
'710inv46520',
'710inv46523',
'710inv46538',
'710inv46542',
'710inv46581',
'710inv46593',
'710inv46601',
'710inv46642',
'710inv46646',
'710inv46648',
'710inv46650',
'710inv46654',
'710inv46668',
'710inv46691',
'710inv46704',
'710inv46754',
'710inv46760',
'710inv46778',
'710inv46788',
'710inv46805',
'710inv46833',
'710inv46879',
'710inv46887',
'710inv46899',
'710inv46922',
'710inv46923',
'710inv46924',
'710inv46925',
'710inv46934',
'710inv46936',
'710inv46965',
'710inv47004',
'710inv47006',
'710inv47041',
'710inv47048',
'710inv47093',
'710inv47110',
'710inv47218',
'710inv47220',
'710inv47225',
'710inv47261',
'710inv47286',
'710inv47316',
'710inv47343',
'710inv47344',
'710inv47354',
'710inv47358',
'710inv47366',
'710inv47384',
'710inv47405',
'710inv47407',
'710inv47410',
'710inv47415',
'710inv47420',
'710inv47432',
'710inv47448',
'710inv47530',
'710inv47544',
'710inv47548',
'710inv47558',
'710inv47611',
'710inv47614',
'710inv47617',
'710inv47627',
'710inv47632',
'710inv47651',
'710inv47769',
'710inv46505',
'710inv46638',
'710inv46720',
'710inv46914',
'710inv47011',
'710inv47022',
'710inv47023',
'710inv47260',
'710inv47272',
'710inv47528',
'710inv47637',
'710inv47767',
'710inv46408',
'710inv46674',
'710inv46845',
'710inv46865',
'710inv46943',
'710inv47008',
'710inv47210',
'710inv47307',
'710inv47355',
'710inv47447',
'710inv47579',
'710inv47768')

               
        ),
        v_pivot AS
        (
                SELECT
                        v_main.*,
                        LEAD(Artigo,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo2,
                        LEAD(Descricao,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao2,
                        LEAD(codiva,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva2,
                        LEAD(UnitPrice,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice2,
                        LEAD(LineDiscount,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount2,
                        LEAD(Quantity,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity2,
                        LEAD(Start_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period2,
                        LEAD(End_date_period,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period2,
                        LEAD(specialization,1) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization2,
                        
                        LEAD(Artigo,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo3,
                        LEAD(Descricao,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao3,
                        LEAD(codiva,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva3,
                        LEAD(UnitPrice,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice3,
                        LEAD(LineDiscount,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount3,
                        LEAD(Quantity,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity3,
                        LEAD(Start_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period3,
                        LEAD(End_date_period,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period3,
                        LEAD(specialization,2) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization3,
                        
                        LEAD(Artigo,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo4,
                        LEAD(Descricao,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao4,
                        LEAD(codiva,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva4,
                        LEAD(UnitPrice,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice4,
                        LEAD(LineDiscount,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount4,
                        LEAD(Quantity,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity4,
                        LEAD(Start_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period4,
                        LEAD(End_date_period,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period4,
                        LEAD(specialization,3) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization4,
                        
                        LEAD(Artigo,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Artigo5,
                        LEAD(Descricao,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Descricao5,
                        LEAD(codiva,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS codiva5,
                        LEAD(UnitPrice,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS UnitPrice5,
                        LEAD(LineDiscount,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS LineDiscount5,
                        LEAD(Quantity,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Quantity5,
                        LEAD(Start_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS Start_date_period5,
                        LEAD(End_date_period,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS End_date_period5,
                        LEAD(specialization,4) OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS specialization5,
                          
                        ROW_NUMBER() OVER (PARTITION BY serie,paymentDate,Referencia,CDU_ExerpID,CDU_ExerpTotalDocument,DueDate,person_center,person_id,inv_center,inv_id,CDU_ExerpTotalDocument,CDU_EasyPayID ORDER BY v_main.subid) AS ADDONSEQ
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
) r1