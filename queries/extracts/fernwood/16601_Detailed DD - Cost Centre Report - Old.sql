-- The extract is extracted from Exerp on 2026-02-08
-- Manual credits not pulling through to this report
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT
        t1."ExerpId"
        ,t1."Amount including VAT (Exerp)"
        ,t1."Transaction Detail"
        ,t1."Product Name"
        ,t1."Payment Request date and Time"
        ,t1."Amount"
        ,t1."Cost Center"
        ,t1."Payment request Reference" 
        ,t1."Payway Customer Number"
        ,t1."Amount including VAT (Exerp)" - t2.total AS "Balance Carried Over"
FROM
        (                
        --Account Transactions
        SELECT
                accounttrans."ExerpId"
                ,accounttrans."Amount including VAT (Exerp)"
                ,accounttrans."Transaction Detail"
                ,accounttrans."Payment Request date and Time"
                ,accounttrans."Amount"
                ,accounttrans."Cost Center"
                ,accounttrans."Payment request Reference" 
                ,accounttrans."Payway Customer Number"
                ,NULL AS "Product Name"
        FROM
                (
                SELECT
                        p.center||'p'||p.id AS "ExerpId"
                        ,pr.req_amount AS "Amount including VAT (Exerp)"
                        ,act.text AS "Transaction Detail"
                        ,longtodatec(pr.entry_time,pr.center) AS "Payment Request date and Time"
                        ,sum(-art.collected_amount) AS "Amount"
                        ,credit.name AS "Cost Center"              
                        ,prs.ref AS "Payment request Reference" 
                        ,pag.ref AS "Payway Customer Number"
                FROM
                        payment_requests pr
                JOIN 
                        payment_request_specifications prs
                        ON prs.center = pr.inv_coll_center
                        AND prs.id = pr.inv_coll_id
                        AND prs.subid = pr.inv_coll_subid
                JOIN
                        payment_agreements pag
                        ON pr.center = pag.center 
                        AND pr.id = pag.id 
                        AND pr.agr_subid = pag.subid     
                JOIN 
                        account_receivables ar 
                        ON ar.center = pag.center 
                        AND ar.id = pag.id
                JOIN 
                        persons p 
                        ON p.center = ar.customercenter 
                        AND p.id = ar.customerid
                JOIN
                        ar_trans art
                        ON art.payreq_spec_center = prs.center
                        AND art.payreq_spec_id = prs.id
                        AND art.payreq_spec_subid = prs.subid
                        AND art.collected = 1
                JOIN
                        account_trans act
                        ON act.center = art.ref_center
                        AND act.id = art.ref_id
                        AND act.subid = art.ref_subid 
                JOIN
                        accounts credit
                        ON credit.center = act.credit_accountcenter
                        AND credit.id = act.credit_accountid
                JOIN 
                        params 
                        ON params.CENTER_ID = pr.center                                                     
                WHERE
                        pr.state in (3,4)
                        --AND
                        --art.collected_amount != 0
                        AND
                        pr.center IN (:Scope)
                        AND
                        pr.entry_time BETWEEN params.FromDate AND params.ToDate
                GROUP BY
                        p.center
                        ,p.id
                        ,pr.req_amount
                        ,act.text
                        ,pr.entry_time
                        ,pr.center
                        ,prs.ref
                        ,pag.ref
                        ,credit.name               
                )accounttrans        
        UNION ALL
        --Invoices
        SELECT
                invoices."ExerpId"
                ,invoices."Amount including VAT (Exerp)"
                ,invoices."Transaction Detail"
                ,invoices."Payment Request date and Time"
                ,invoices."Amount"
                ,invoices."Cost Center"
                ,invoices."Payment request Reference" 
                ,invoices."Payway Customer Number"
                ,invoices."Product Name"                
        FROM
                (
                SELECT
                        p.center||'p'||p.id AS "ExerpId"
                        ,pr.req_amount AS "Amount including VAT (Exerp)"
                        ,act.text AS "Transaction Detail"
                        ,longtodatec(pr.entry_time,pr.center) AS "Payment Request date and Time"
                        ,sum(invl.total_amount) AS "Amount"
                        ,credit.name AS "Cost Center"
                        ,prs.ref AS "Payment request Reference" 
                        ,pag.ref AS "Payway Customer Number"
                        ,prod.name AS "Product Name"
                FROM
                        payment_requests pr
                JOIN 
                        payment_request_specifications prs
                        ON prs.center = pr.inv_coll_center
                        AND prs.id = pr.inv_coll_id
                        AND prs.subid = pr.inv_coll_subid
                JOIN
                        payment_agreements pag
                        ON pr.center = pag.center 
                        AND pr.id = pag.id 
                        AND pr.agr_subid = pag.subid     
                JOIN 
                        account_receivables ar 
                        ON ar.center = pag.center 
                        AND ar.id = pag.id
                JOIN 
                        persons p 
                        ON p.center = ar.customercenter 
                        AND p.id = ar.customerid
                JOIN
                        ar_trans art
                        ON art.payreq_spec_center = prs.center
                        AND art.payreq_spec_id = prs.id
                        AND art.payreq_spec_subid = prs.subid
                        AND art.collected = 1
                        AND art.ref_type IN ('INVOICE') 
                JOIN
                        invoice_lines_mt invl
                        ON invl.center = art.ref_center
                        AND invl.id = art.ref_id
                        AND invl.installment_plan_id IS NULL
                LEFT JOIN
                        products prod
                        ON prod.center = invl.productcenter
                        AND prod.id = invl.productid                         
                JOIN
                        account_trans act
                        ON invl.account_trans_center = act.center
                        AND invl.account_trans_id = act.id
                        AND invl.account_trans_subid  = act.subid                
                JOIN
                        accounts credit
                        ON credit.center = act.credit_accountcenter
                        AND credit.id = act.credit_accountid                             
                JOIN 
                        params 
                        ON params.CENTER_ID = pr.center                                                     
                WHERE
                        pr.state in (3,4)
                        AND
                        pr.center IN (:Scope)
                        AND
                        pr.entry_time BETWEEN params.FromDate AND params.ToDate
                GROUP BY
                        p.center
                        ,p.id
                        ,pr.req_amount
                        ,act.text
                        ,pr.entry_time
                        ,pr.center
                        ,prs.ref
                        ,pag.ref
                        ,credit.name
                        ,prod.name                 
                )invoices  
        )t1
JOIN
        (
        SELECT
                t."ExerpId"
                ,sum(t."Amount") AS Total
                ,t."Payment request Reference" 
        FROM 
                (                       
                --Account Transactions
                SELECT
                        accounttrans."ExerpId"
                        ,accounttrans."Amount including VAT (Exerp)"
                        ,accounttrans."Transaction Detail"
                        ,accounttrans."Payment Request date and Time"
                        ,accounttrans."Amount"
                        ,accounttrans."Cost Center"
                        ,accounttrans."Payment request Reference" 
                        ,accounttrans."Payway Customer Number"
                FROM
                        (
                        SELECT
                                p.center||'p'||p.id AS "ExerpId"
                                ,pr.req_amount AS "Amount including VAT (Exerp)"
                                ,act.text AS "Transaction Detail"
                                ,longtodatec(pr.entry_time,pr.center) AS "Payment Request date and Time"
                                ,sum(-art.collected_amount) AS "Amount"
                                ,credit.name AS "Cost Center"              
                                ,prs.ref AS "Payment request Reference" 
                                ,pag.ref AS "Payway Customer Number"
                        FROM
                                payment_requests pr
                        JOIN 
                                payment_request_specifications prs
                                ON prs.center = pr.inv_coll_center
                                AND prs.id = pr.inv_coll_id
                                AND prs.subid = pr.inv_coll_subid
                        JOIN
                                payment_agreements pag
                                ON pr.center = pag.center 
                                AND pr.id = pag.id 
                                AND pr.agr_subid = pag.subid     
                        JOIN 
                                account_receivables ar 
                                ON ar.center = pag.center 
                                AND ar.id = pag.id
                        JOIN 
                                persons p 
                                ON p.center = ar.customercenter 
                                AND p.id = ar.customerid
                        JOIN
                                ar_trans art
                                ON art.payreq_spec_center = prs.center
                                AND art.payreq_spec_id = prs.id
                                AND art.payreq_spec_subid = prs.subid
                                AND art.collected = 1
                        JOIN
                                account_trans act
                                ON act.center = art.ref_center
                                AND act.id = art.ref_id
                                AND act.subid = art.ref_subid 
                        JOIN
                                accounts credit
                                ON credit.center = act.credit_accountcenter
                                AND credit.id = act.credit_accountid                             
                        JOIN 
                                params 
                                ON params.CENTER_ID = pr.center                                                     
                        WHERE
                                pr.state in (3,4)
                                --AND
                                --art.collected_amount != 0
                                AND
                                pr.center IN (:Scope)
                                AND
                                pr.entry_time BETWEEN params.FromDate AND params.ToDate
                        GROUP BY
                                p.center
                                ,p.id
                                ,pr.req_amount
                                ,act.text
                                ,pr.entry_time
                                ,pr.center
                                ,prs.ref
                                ,pag.ref
                                ,credit.name               
                        )accounttrans        
                UNION ALL
                --Invoices
                SELECT
                        invoices."ExerpId"
                        ,invoices."Amount including VAT (Exerp)"
                        ,invoices."Transaction Detail"
                        ,invoices."Payment Request date and Time"
                        ,invoices."Amount"
                        ,invoices."Cost Center"
                        ,invoices."Payment request Reference" 
                        ,invoices."Payway Customer Number"
                FROM
                        (
                        SELECT
                                p.center||'p'||p.id AS "ExerpId"
                                ,pr.req_amount AS "Amount including VAT (Exerp)"
                                ,act.text AS "Transaction Detail"
                                ,longtodatec(pr.entry_time,pr.center) AS "Payment Request date and Time"
                                ,sum(invl.total_amount) AS "Amount"
                                ,credit.name AS "Cost Center"
                                ,prs.ref AS "Payment request Reference" 
                                ,pag.ref AS "Payway Customer Number"
                        FROM
                                payment_requests pr
                        JOIN 
                                payment_request_specifications prs
                                ON prs.center = pr.inv_coll_center
                                AND prs.id = pr.inv_coll_id
                                AND prs.subid = pr.inv_coll_subid
                        JOIN
                                payment_agreements pag
                                ON pr.center = pag.center 
                                AND pr.id = pag.id 
                                AND pr.agr_subid = pag.subid     
                        JOIN 
                                account_receivables ar 
                                ON ar.center = pag.center 
                                AND ar.id = pag.id
                        JOIN 
                                persons p 
                                ON p.center = ar.customercenter 
                                AND p.id = ar.customerid
                        JOIN
                                ar_trans art
                                ON art.payreq_spec_center = prs.center
                                AND art.payreq_spec_id = prs.id
                                AND art.payreq_spec_subid = prs.subid
                                AND art.collected = 1
                                AND art.ref_type IN ('INVOICE') 
                        JOIN
                                invoice_lines_mt invl
                                ON invl.center = art.ref_center
                                AND invl.id = art.ref_id
                                AND invl.installment_plan_id IS NULL
                        JOIN
                                account_trans act
                                ON invl.account_trans_center = act.center
                                AND invl.account_trans_id = act.id
                                AND invl.account_trans_subid  = act.subid                
                        JOIN
                                accounts credit
                                ON credit.center = act.credit_accountcenter
                                AND credit.id = act.credit_accountid                             
                        JOIN 
                                params 
                                ON params.CENTER_ID = pr.center                                                     
                        WHERE
                                pr.state in (3,4)
                                AND
                                pr.center IN (:Scope)
                                AND
                                pr.entry_time BETWEEN params.FromDate AND params.ToDate
                        GROUP BY
                                p.center
                                ,p.id
                                ,pr.req_amount
                                ,act.text
                                ,pr.entry_time
                                ,pr.center
                                ,prs.ref
                                ,pag.ref
                                ,credit.name                 
                        )invoices                                         
                )t                        
                GROUP BY
                        t."ExerpId"
                        ,t."Payment request Reference" 
        )t2
        ON t1."ExerpId" = t2."ExerpId"
        AND t1."Payment request Reference" = t2."Payment request Reference" 