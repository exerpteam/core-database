-- The extract is extracted from Exerp on 2026-02-08
-- EC-7485 - New fusion report
SELECT
        t."BusinessUnitName"
        ,t."ReceiptMethodName"
        ,t."ReceiptNumber"
        ,t.crt_type
        ,t.ReceiptDate
        ,t.GlDate                                                           
        ,t."Amount"
        ,t."CustomerName"                        
        ,t."CustomerAccountNumber"
        ,t."CurrencyCode"
        ,t."Club Number"
        ,t."Exerp Invoice ID"
        ,t."Payment Source"
        --,t.a
FROM
(
SELECT DISTINCT --Note for Paytabs: PTB used for UAE clubs and PTS used for KSA clubs
                t1."BusinessUnitName"
                ,'' AS "ReceiptMethodName"
                ,t1."ReceiptNumber"
                ,t1.crt_type
                ,TO_CHAR(longtodatec(t1."ReceiptDate" ,t1.center),'yyyy-MM-dd') AS ReceiptDate
                ,TO_CHAR(longtodatec(t1."GlDate",t1.center),'yyyy-MM-dd') AS GlDate                                                           
                ,CAST(ROUND(t1."Amount",2) AS VARCHAR) AS "Amount"
                ,CASE
                        WHEN t1."CustomerAccountNumber" IS NULL THEN transfer.fullname 
                        ELSE t1."CustomerName"
                END AS "CustomerName"                        
                ,CASE
                        WHEN t1."CustomerAccountNumber" IS NULL THEN transfer.external_id
                        ELSE t1."CustomerAccountNumber"
                END AS "CustomerAccountNumber"
                ,t1."CurrencyCode"
                ,CAST(t1."Club Number" AS VARCHAR) AS "Club Number"
                ,t1."Exerp Invoice ID"
                ,CASE
                        WHEN t1.sex = 'C' THEN 'Company'
                        ELSE 'Individual'
                END AS "Payment Source"
                ,t1.a 
                ,t1.subid                                   
FROM       
       (       
        WITH
          params AS MATERIALIZED
          (
              SELECT
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1 AS ToDate
              FROM
                  centers c
         )        
        SELECT
                crt_trans.businessunitname      AS "BusinessUnitName"
                ,crt_trans.gl_account            AS gl_account
                ,crt_trans.crt_type              AS crt_type
                ,crt_trans.crt_center            AS crt_center
                ,crt_trans.inv_center            AS inv_center
                ,crt_trans.coment                AS coment
                ,crt_trans.art_info              AS art_info
                ,crt_trans.transaction_id        AS transaction_id
                ,crt_trans.receiptnumber         AS "ReceiptNumber"
                ,crt_trans.ReceiptDate           AS "ReceiptDate"
                ,crt_trans.GlDate                AS "GlDate"
                ,SUM(crt_trans.Amount)           AS "Amount"
                ,crt_trans.CustomerName          AS "CustomerName"
                ,crt_trans.CustomerAccountNumber AS "CustomerAccountNumber"
                ,crt_trans.pcenter               AS pcenter
                ,crt_trans.pid                   AS pid
                ,crt_trans.CurrencyCode          AS "CurrencyCode"
                ,crt_trans.ClubNumber            AS "Club Number"
                ,crt_trans.ExerpInvoiceID        AS "Exerp Invoice ID"
                ,crt_trans.center
                ,crt_trans.sex
                ,crt_trans.a AS a
                ,crt_trans.subid
        FROM
            (
                SELECT
                    c.org_code2    AS BusinessUnitName 
                    ,ac.external_id AS gl_account 
                    ,CRTTYPE        AS crt_type 
                    ,CASE
                        WHEN CRT.CENTER IN (100,101) THEN INV.CENTER
                        ELSE CRT.CENTER
                    END AS crt_center 
                    ,INV.CENTER     AS inv_center 
                    ,crt.coment     AS coment 
                    ,NULL           AS art_info 
                    ,NULL           AS transaction_id 
                    ,CASE
                        WHEN CRTTYPE = 13 THEN crt.coment
                        WHEN cct.receipt_number IS NOT NULL THEN cct.receipt_number
                        WHEN gc.identity IS NOT NULL THEN gc.identity
                        WHEN cct.receipt_number IS NULL AND cct.transaction_id IS NOT NULL THEN cct.transaction_id
                        WHEN cct.receipt_number IS NULL AND cct.transaction_id IS NULL AND inv.center IS NOT NULL THEN inv.center||'inv'||inv.id
                        ELSE cnt.center||'cred'||cnt.id
                    END AS ReceiptNumber 
                    ,CASE
                        WHEN arti.center IS NOT NULL THEN arti.entry_time
                        WHEN artc.center IS NOT NULL THEN artc.entry_time
                        ELSE crt.transtime
                    END AS ReceiptDate 
                    ,CASE
                        WHEN arti.center IS NOT NULL THEN arti.trans_time
                        WHEN artc.center IS NOT NULL THEN artc.trans_time
                        ELSE crt.transtime
                    END AS GlDate 
                    ,CASE
                        WHEN crt.amount > invl.total_amount THEN invl.total_amount
                        ELSE crt.amount
                    END           AS Amount 
                    ,p.fullname    AS CustomerName 
                    ,p.external_id AS CustomerAccountNumber 
                    ,p.center      AS pcenter 
                    ,p.id          AS pid 
                    ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                    END        AS CurrencyCode
                    ,crt.center AS ClubNumber 
                    ,CASE
                        WHEN inv.center IS NOT NULL THEN inv.center||'inv'||inv.id
                        ELSE cnt.center||'cred'||cnt.id
                    END AS ExerpInvoiceID 
                    ,crt.center 
                    ,p.sex 
                    ,crt.subid
                    ,1 AS a
                FROM
                        cashregistertransactions crt
                JOIN
                        centers c
                                ON c.id = crt.center
                JOIN params
                                ON params.CENTER_ID = crt.center
                LEFT JOIN
                        invoices inv
                                ON inv.paysessionid = crt.paysessionid
                                AND inv.cashregister_center = crt.center
                                AND inv.cashregister_id = crt.id
                LEFT JOIN
                        invoice_lines_mt invl
                                ON inv.center = invl.center
                                AND inv.id = invl.id
                LEFT JOIN
                        ar_trans arti
                                ON arti.ref_center = invl.center
                                AND arti.ref_id = invl.id
                                AND arti.ref_subid = invl.subid
                LEFT JOIN
                        credit_notes cnt
                                ON cnt.paysessionid = crt.paysessionid
                                AND cnt.cashregister_center = crt.center
                                AND cnt.cashregister_id = crt.id
                LEFT JOIN
                        credit_note_lines_mt cntl
                                ON cnt.center = cntl.center
                                AND cnt.id = cntl.id
                LEFT JOIN
                        ar_trans artc
                                ON artc.ref_center = cntl.center
                                AND artc.ref_id = cntl.id
                                AND artc.ref_subid = cntl.subid
                                AND artc.ref_type = 'CREDIT_NOTE'
                LEFT JOIN
                        persons p
                                ON p.center = crt.customercenter
                                AND p.id = crt.customerid
                LEFT JOIN
                        creditcardtransactions cct
                                ON cct.gl_trans_center = crt.gltranscenter
                                AND cct.gl_trans_id = crt.gltransid
                                AND cct.gl_trans_subid = crt.gltranssubid
                LEFT JOIN
                        leejam.account_trans act
                                ON act.center = invl.account_trans_center
                                AND act.id = invl.account_trans_id
                                AND act.subid = invl.account_trans_subid
                LEFT JOIN
                        leejam.accounts ac
                                ON ac.center = act.debit_accountcenter
                                AND ac.id = act.debit_accountid
                LEFT JOIN
                        (
                        SELECT 
                                gcu.transaction_center
                                ,gcu.transaction_id
                                ,gcu.transaction_subid
                                ,ei.identity     
                        FROM
                                leejam.gift_cards gc 
                        JOIN 
                                leejam.entityidentifiers ei
                                ON gc.center = ei.ref_center 
                                AND gc.id = ei.ref_id 
                                AND ei.ref_type = 5
                        JOIN
                                leejam.gift_card_usages gcu
                                ON gcu.gift_card_center = gc.center
                                AND gcu.gift_card_id = gc.id
                        )gc
                                ON gc.transaction_center= crt.gltranscenter
                                AND gc.transaction_id = crt.gltransid
                                AND gc.transaction_subid = crt.gltranssubid                                  
                WHERE
                        crt.center IN (:Scope)
                        AND 
                        crt.transtime BETWEEN params.FromDate AND params.ToDate
                        AND 
                        crt.CRTTYPE NOT IN (4,5,10,11,14,15,16,17,18,19,20,21,100,101)) crt_trans
        GROUP BY
            crt_trans.businessunitname
            ,crt_trans.gl_account
            ,crt_trans.crt_type
            ,crt_trans.crt_center
            ,crt_trans.inv_center
            ,crt_trans.coment
            ,crt_trans.art_info
            ,crt_trans.transaction_id
            ,crt_trans.receiptnumber
            ,crt_trans.ReceiptDate
            ,crt_trans.GlDate
            ,crt_trans.CustomerName
            ,crt_trans.CustomerAccountNumber
            ,crt_trans.pcenter
            ,crt_trans.pid
            ,crt_trans.CurrencyCode
            ,crt_trans.ClubNumber
            ,crt_trans.ExerpInvoiceID
            ,crt_trans.center
            ,crt_trans.sex
            ,crt_trans.a
            ,crt_trans.subid    
        UNION ALL
        SELECT  
                c.org_code2 AS "BusinessUnitName" 
                ,NULL as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,art.info AS "ReceiptNumber"
                ,art.trans_time AS "ReceiptDate"   
                ,armatch.trans_time AS "GlDate"                                                 
                ,art.amount AS "Amount"
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,art.center AS "Club Number"
                ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                ,art.center
                ,p.sex
                ,2 as a
                ,0 AS subid
        FROM 
                account_receivables ar
        JOIN
                ar_trans art   
                        ON art.center = ar.center    
                        AND art.id = ar.id
                        AND art.ref_type = 'ACCOUNT_TRANS' 
        JOIN
                art_match payment
                        ON payment.art_paying_center = art.center
                        AND payment.art_paying_id = art.id
                        AND payment.art_paying_subid = art.subid
        JOIN       
                ar_trans armatch
                        ON payment.art_paid_center = armatch.center
                        AND payment.art_paid_id = armatch.id
                        AND payment.art_paid_subid = armatch.subid
        JOIN
                invoices inv
                        ON armatch.ref_center = inv.center
                        AND armatch.ref_id = inv.id
        JOIN
                centers c
                        ON c.id = art.center
        JOIN
                persons p
                        ON p.center = ar.customercenter
                        AND p.id = ar.customerid
        JOIN 
                params 
                        ON params.CENTER_ID = art.center                                        
        WHERE 
                ar.center IN (:Scope)
                AND
                ar.ar_type IN (1,4)
                AND
                art.employeecenter ||'emp'||art.employeeid in ('100emp2002','100emp4202','100emp12801','100emp23002','100emp23402','100emp19001')
                AND 
                art.text IN ('API Sale Transaction','API Product Sale','API Register remaining money from payment request')
                AND 
                art.trans_time BETWEEN params.FromDate AND params.ToDate 
        UNION ALL
        SELECT  
                c.org_code2 AS "BusinessUnitName" 
                ,debit.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,NULL AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,NULL AS transaction_id
                ,debit.name||' '||debit.external_id AS "ReceiptNumber"
                ,payment.trans_time AS "ReceiptDate"   
                ,payment.trans_time AS "GlDate"                                                 
                ,payment.amount AS "Amount"
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,payment.center AS "Club Number"
                ,payment.ref_center||'acc'||payment.ref_id||'tr'||payment.ref_subid AS "Exerp Invoice ID"
                ,payment.center
                ,p.sex
                ,3 as a
                ,0 AS subid
        FROM 
                account_trans act
        JOIN
                centers c                
                        ON c.id = act.center
        JOIN
                ar_trans payment
                        ON act.center = payment.ref_center
                        AND act.id = payment.ref_id
                        AND act.subid = payment.ref_subid
        JOIN
                art_match armatch  
                        ON payment.center = armatch.art_paying_center
                        AND payment.id = armatch.art_paying_id                
                        AND payment.subid = armatch.art_paying_subid                              
        JOIN      
                ar_trans art        
                        ON armatch.art_paid_center = art.center
                        AND armatch.art_paid_id = art.id
                        AND armatch.art_paid_subid = art.subid
                        AND art.ref_type = 'INVOICE'
        JOIN
                invoice_lines_mt invl
                        ON invl.center = art.ref_center
                        AND invl.id = art.ref_id
                        AND invl.subid = art.ref_subid
        JOIN
                invoices inv
                        ON invl.center = inv.center
                        AND invl.id = inv.id                        
        JOIN
                persons p
                        ON p.center = inv.payer_center        
                        AND p.id = inv.payer_id
                        AND p.persontype = 4
        JOIN 
                params 
                        ON params.CENTER_ID = p.center 
        LEFT JOIN
                ACCOUNTS debit
                        ON debit.CENTER = act.DEBIT_ACCOUNTCENTER
                        AND debit.ID = act.DEBIT_ACCOUNTID
        LEFT JOIN
                ACCOUNTS credit
                        ON credit.CENTER = act.CREDIT_ACCOUNTCENTER
                        AND credit.ID = act.CREDIT_ACCOUNTID
        LEFT JOIN
                VAT_TYPES at
                        ON at.CENTER = act.VAT_TYPE_CENTER
                        AND at.id = act.VAT_TYPE_ID                                                               
        WHERE
                act.entry_time BETWEEN params.FromDate AND params.ToDate 
                AND
                act.info_type != 2
                AND 
                act.center IN (:Scope)
        UNION ALL
        SELECT --payment link     
                c.org_code2 AS "BusinessUnitName" 
               	,ac.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,cct.transaction_id AS transaction_id
                ,cct.transaction_id AS "ReceiptNumber"
                ,act.entry_time AS "ReceiptDate"   
                ,act.entry_time AS "GlDate"                                                 
                ,cct.amount AS "Amount"
                ,p.fullname AS "CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,act.center AS "Club Number"
                ,invoice.center||'inv'||invoice.id AS "Exerp Invoice ID"
                ,act.center
                ,p.sex
                ,4 as a
                ,0 AS subid
        FROM
                account_trans act
        JOIN
                creditcardtransactions cct
                        ON cct.gl_trans_center = act.center
                        AND cct.gl_trans_id = act.id
                        AND cct.gl_trans_subid = act.subid
        JOIN
                centers c
                        ON c.id = act.center        
        JOIN
                (SELECT
                        inv.payer_center||'p'||inv.payer_id AS PersonID
                        ,TO_CHAR(longtodatec(inv.trans_time,inv.center), 'YYYY-MM-DD HH') AS InvoiceDate
                        ,sum(invl.total_amount) AS InvoiceAmount
                        ,inv.center
                        ,inv.id
                FROM
                        invoices inv
                JOIN
                        invoice_lines_mt invl
                                ON inv.center = invl.center
                                AND inv.id = invl.id        
                GROUP BY
                        inv.payer_center
                        ,inv.payer_id 
                        ,inv.trans_time
                        ,inv.center
                        ,inv.id
                )invoice
                        ON invoice.PersonID = left(act.text, strpos(act.text, ': ') - 1)
                        AND invoice.InvoiceAmount = act.amount
                        AND invoice.InvoiceDate = TO_CHAR(longtodatec(act.entry_time,act.center), 'YYYY-MM-DD HH')
        JOIN
                invoices inv
                        ON inv.center = invoice.center
                        AND inv.id = invoice.id
        JOIN
                persons p
                        ON p.center = inv.payer_center
                        AND p.id = inv.payer_id
        JOIN
                leejam.accounts ac
                ON ac.center = act.debit_accountcenter
                AND ac.id = act.debit_accountid                         
        JOIN 
                params 
                        ON params.CENTER_ID = act.center                                
        WHERE 
                cct.transaction_state = 2
                AND
                act.center IN (:Scope)
                AND
                act.entry_time BETWEEN params.FromDate AND params.ToDate
        UNION ALL
        SELECT --Manual account trasnactions
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,NULL AS crt_type
                ,NULL AS crt_center 
                ,NULL AS inv_center
                ,NULL AS coment  
                ,NULL AS art_info
                ,NULL AS transaction_id
                ,act.text AS "ReceiptNumber"
                ,act.entry_time AS "ReceiptDate"   
                ,act.entry_time AS "GlDate"                                                 
                ,act.amount AS "Amount"
                ,p.fullname AS "CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,act.center AS "Club Number"
                ,NULL AS "Exerp Invoice ID"
                ,act.center
                ,p.sex
                ,5 as a
                ,0 AS subid
        FROM
                account_receivables ar
        JOIN
                persons p             
                ON p.center = ar.customercenter
                AND p.id = ar.customerid
                AND p.sex = 'C'                        
        JOIN
                ar_trans art   
                ON art.center = ar.center    
                AND art.id = ar.id
                AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
                account_trans act
                ON act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid
                AND act.info_type NOT IN (1,2)
        JOIN
                centers c
                ON c.id = act.center
        JOIN
                accounts ac
                ON ac.center = act.debit_accountcenter
                AND ac.id = act.debit_accountid
                AND ac.external_id != 'NO_FUSION'                
        JOIN
                params
                ON params.center_id = act.center                                                        
        WHERE
                act.center IN (:Scope)
                AND
                act.entry_time BETWEEN params.FromDate AND params.ToDate
        UNION ALL
        SELECT  --pasrtially used credit notes - Exclude reassignments
                t."BusinessUnitName" 
                ,t.gl_account
                ,min(t.crt_type) AS crt_type 
                ,t.crt_center 
                ,t.inv_center
                ,t.coment  
                ,t.art_info
                ,t.transaction_id
                ,t."ReceiptNumber"
                ,t."ReceiptDate"   
                ,t."GlDate"                                                 
                ,t."Amount" 
                ,t."CustomerName"
                ,t."CustomerAccountNumber"
                ,t.pcenter
                ,t.pid
                ,t."CurrencyCode"
                ,t."Club Number"
                ,t."Exerp Invoice ID"
                ,t.center
                ,t.sex
                ,t.a
                ,0 AS subid
        FROM
        (                
                SELECT DISTINCT
                        c.org_code2 AS "BusinessUnitName" 
                        ,ac.external_id as gl_account
                        ,crt.CRTTYPE AS crt_type
                        ,CASE 
                                WHEN CRT.CENTER IN (100,101) THEN INV.CENTER
                                ELSE CRT.CENTER
                        END AS crt_center 
                        ,INV.CENTER AS inv_center
                        ,crt.coment AS coment  
                        ,NULL AS art_info
                        ,NULL AS transaction_id
                        ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                        ,cnt.trans_time AS "ReceiptDate"   
                        ,cnt.trans_time AS "GlDate"                                                 
                        ,CASE
                                WHEN art.center IS NOT NULL THEN -(cntl.total_amount+art.amount)
                                ELSE -crt.amount
                        END AS "Amount" 
                        --,-crt.amount AS "Amount"
                        ,p.fullname AS"CustomerName"
                        ,p.external_id AS "CustomerAccountNumber"
                        ,p.center as pcenter
                        ,p.id as pid
                        ,CASE
                                WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                                WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                        END AS "CurrencyCode"
                        ,cnt.center AS "Club Number"
                        ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                        ,cnt.center
                        ,p.sex
                        ,6 as a
                FROM 
                        cashregistertransactions crt
                
                 JOIN 
                        params 
                                ON params.CENTER_ID = crt.center 
                JOIN
                        invoices inv
                                ON inv.paysessionid = crt.paysessionid
                                AND inv.cashregister_center = crt.center
                                AND inv.cashregister_id = crt.id
                JOIN
                        invoice_lines_mt invl  
                                ON inv.center = invl.center
                                AND inv.id = invl.id
                JOIN
                        credit_notes cnt
                                ON cnt.invoice_center = inv.center
                                AND cnt.invoice_id = inv.id
                JOIN
                        centers c
                                ON c.id = cnt.center 
                JOIN 
                        credit_note_lines_mt cntl 
                                ON cnt.center = cntl.center
                                AND cnt.id = cntl.id 
                                AND cntl.reason != 6
                JOIN
                        account_trans act
                                ON act.center = invl.account_trans_center
                                AND act.id = invl.account_trans_id 
                                AND act.subid = invl.account_trans_subid
                JOIN
                        ACCOUNTS ac
                                ON ac.CENTER = act.debit_accountcenter
                                AND ac.ID = act.debit_accountid
                LEFT JOIN
                        persons p
                                ON p.center = crt.customercenter
                                AND p.id = crt.customerid 
               
                LEFT JOIN
                        cashregistertransactions crtcn
                                ON cnt.paysessionid = crtcn.paysessionid
                                AND cnt.cashregister_center = crtcn.center
                                AND cnt.cashregister_id = crtcn.id 
                
                LEFT JOIN
                        ar_trans artc                              
                                ON artc.ref_center = cntl.center
                                AND artc.ref_id = cntl.id
                                AND artc.ref_type = 'CREDIT_NOTE' 
                LEFT JOIN
                        art_match armatch  
                                ON artc.center = armatch.art_paying_center
                                AND artc.id = armatch.art_paying_id                
                                AND artc.subid = armatch.art_paying_subid
                                AND armatch.used_rule = 1
                LEFT JOIN      
                        ar_trans art        
                                ON armatch.art_paid_center = art.center
                                AND armatch.art_paid_id = art.id
                                AND armatch.art_paid_subid = art.subid
                                AND art.ref_type = 'INVOICE'                                             
                WHERE
                        crt.center IN (:Scope)
                        AND
                        cnt.trans_time BETWEEN params.FromDate AND params.ToDate 
                        AND 
                        crt.CRTTYPE NOT IN (5,10,11,15,16,19,20)  
                        AND
                        ac.external_id != 'NO_FUSION'
                        AND
                        cntl.reason != 36 
        )t
        WHERE
                t."Amount" != 0
        GROUP BY
                t."BusinessUnitName" 
                ,t.gl_account
                ,t.crt_center 
                ,t.inv_center
                ,t.coment  
                ,t.art_info
                ,t.transaction_id
                ,t."ReceiptNumber"
                ,t."ReceiptDate"   
                ,t."GlDate"                                                 
                ,t."Amount" 
                ,t."CustomerName"
                ,t."CustomerAccountNumber"
                ,t.pcenter
                ,t.pid
                ,t."CurrencyCode"
                ,t."Club Number"
                ,t."Exerp Invoice ID"
                ,t.center
                ,t.sex
                ,t.a                         
        UNION ALL
        SELECT DISTINCT -- transaction not going through cash register
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,0 AS crt_type
                ,0 AS crt_center 
                ,INV.CENTER AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                ,cnt.trans_time AS "ReceiptDate"   
                ,cnt.trans_time AS "GlDate"                                                 
                ,-cntl.total_amount AS "Amount" 
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,cnt.center AS "Club Number"
                ,inv.center||'inv'||inv.id AS "Exerp Invoice ID"
                ,cnt.center
                ,p.sex
                ,7 as a
                ,0 AS subid                    
        FROM
                credit_notes cnt
        JOIN
                credit_note_lines_mt cntl
                ON cnt.center = cntl.center
                AND cnt.id = cntl.id 
                AND cntl.total_amount != 0    
        JOIN
                invoices inv
                ON inv.center = cnt.invoice_center
                AND inv.id = cnt.invoice_id 
        JOIN
                invoice_lines_mt invl
                ON invl.center = inv.center
                AND invl.id = inv.id
                AND invl.reason != 6
        JOIN   
                leejam.account_trans act
                ON act.center = cntl.account_trans_center
                AND act.id = cntl.account_trans_id
                AND act.subid = cntl.account_trans_subid           
        JOIN
                ACCOUNTS ac
                ON ac.CENTER = act.debit_accountcenter
                AND ac.ID = act.debit_accountid  
        JOIN
                centers c
                ON c.id = cnt.center   
        JOIN 
                params 
                ON params.CENTER_ID = cnt.center 
        LEFT JOIN
                persons p
                ON p.center = cnt.payer_center
                AND p.id = cnt.payer_id
        
        LEFT JOIN 
                ar_trans armatch
                ON invl.center = armatch.ref_center
                AND invl.id = armatch.ref_id
                AND armatch.ref_type = 'INVOICE'       
        LEFT JOIN
                art_match payment
                ON payment.art_paid_center = armatch.center
                AND payment.art_paid_id = armatch.id
                AND payment.art_paid_subid = armatch.subid
        LEFT JOIN
                ar_trans art   
                ON payment.art_paying_center = art.center
                AND payment.art_paying_id = art.id
                AND payment.art_paying_subid = art.subid                                                            
        LEFT JOIN
                cashregistertransactions crt
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id                                             
        WHERE
                cnt.trans_time BETWEEN params.FromDate AND params.ToDate
                AND
                crt.center IS NULL  
                AND
                cnt.center IN (:Scope)
                AND
                cntl.reason != 36 
        UNION ALL
        SELECT DISTINCT -- unallocated credit notes
                c.org_code2 AS "BusinessUnitName" 
                ,ac.external_id as gl_account
                ,crt.crttype AS crt_type
                ,CASE
                        WHEN crt.center IN (100,101) THEN invl.center
                        ELSE crt.center
                END AS crt_center 
                ,invl.center AS inv_center
                ,NULL AS coment  
                ,art.info AS art_info
                ,NULL AS transaction_id
                ,cnt.center||'cred'||cnt.id AS "ReceiptNumber"
                ,cnt.trans_time AS "ReceiptDate"   
                ,cnt.trans_time AS "GlDate"                                                 
                ,-cntl.total_amount AS "Amount" 
                ,p.fullname AS"CustomerName"
                ,p.external_id AS "CustomerAccountNumber"
                ,p.center as pcenter
                ,p.id as pid
                ,CASE
                        WHEN c.time_zone = 'Asia/Dubai' THEN 'AED'
                        WHEN c.time_zone = 'Asia/Riyadh' THEN 'SAR'
                END AS "CurrencyCode"
                ,cnt.center AS "Club Number"
                ,invl.center||'inv'||invl.id AS "Exerp Invoice ID"
                ,cnt.center
                ,p.sex
                ,8 as a
                ,0 AS subid                 
        FROM
                credit_notes cnt
        JOIN
                credit_note_lines_mt cntl
                ON cnt.center = cntl.center
                AND cnt.id = cntl.id  
        JOIN
                invoice_lines_mt invl
                ON invl.center = cntl.invoiceline_center
                AND invl.id = cntl.invoiceline_id
                AND invl.subid = cntl.invoiceline_subid
        JOIN   
                leejam.account_trans act
                ON act.center = cntl.account_trans_center
                AND act.id = cntl.account_trans_id
                AND act.subid = cntl.account_trans_subid           
        JOIN
                ACCOUNTS ac
                ON ac.CENTER = act.debit_accountcenter
                AND ac.ID = act.debit_accountid  
        JOIN
                centers c
                ON c.id = cnt.center   
        JOIN 
                params 
                ON params.CENTER_ID = cnt.center 
        LEFT JOIN
                persons p
                ON p.center = cnt.payer_center
                AND p.id = cnt.payer_id
        
        LEFT JOIN 
                ar_trans armatch
                ON invl.center = armatch.ref_center
                AND invl.id = armatch.ref_id
                AND armatch.ref_type = 'INVOICE'       
        LEFT JOIN
                art_match payment
                ON payment.art_paid_center = armatch.center
                AND payment.art_paid_id = armatch.id
                AND payment.art_paid_subid = armatch.subid
        LEFT JOIN
                ar_trans art   
                ON payment.art_paying_center = art.center
                AND payment.art_paying_id = art.id
                AND payment.art_paying_subid = art.subid 
        JOIN
                leejam.invoices inv
                ON inv.center = invl.center
                AND inv.id = invl.id
        JOIN
                cashregistertransactions crt
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id                                                                  
        WHERE
                cnt.trans_time BETWEEN params.FromDate AND params.ToDate
                AND
                cnt.center IN (:Scope)  
                AND
                cnt.invoice_center IS NULL  
                AND
                crt.CRTTYPE NOT IN (5,10,11,15,16,19,20)                                                                                           
        )t1
LEFT JOIN
        persons p
        ON t1.pcenter = p.center
        AND t1.pid = p.id
        AND t1."CustomerAccountNumber" is null
LEFT JOIN
        persons transfer
        ON transfer.center = p.transfers_current_prs_center   
        AND transfer.id = p.current_person_id
WHERE
        t1."Amount" != 0  
)t       
      