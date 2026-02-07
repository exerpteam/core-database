WITH PARAMS AS
        (
        SELECT
                TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 month' AS FROM_DATE,
                TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 day' AS TO_DATE,
                c.id
        FROM
                centers c
        )
SELECT
        T2."ExerpId",
        T2."Amount including VAT (Exerp)",
        T2."Product Name",
        T."Balance Carried Forward" - T2."Amount including VAT (Exerp)" AS "Credit/Overdue Debt Carried forward",
        T2."Transaction Text" AS "Transaction Detail",
        T2."Payment Request date and Time",
        T2."Cost Center Amount-new" AS "Amount",
        T2."Cost Center",
        T2."Payment request Reference" ,
        T2."Payway Customer Number"
        --"Transaction Line Amount excluding VAT"        
FROM
                (
                SELECT
                        A."ExerpId",
                        A."Amount including VAT (Exerp)",
                        SUM(A."Cost Center Amount-new") AS "Balance Carried Forward",
                        A."Payment Request date and Time",
                        A."Payment request Reference" ,
                        A."Payway Customer Number"
                FROM
                    (
                        SELECT -- Get invoice type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            prod.name                             AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            act.text                              AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_inv.amount                        AS "Cost Center Amount",
                            ivl.total_amount                      AS "Cost Center Amount-new",
                            pac.sales_account_globalid            AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            act.amount                            AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"  
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) -- Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_inv
                        ON
                            art_inv.PAYREQ_SPEC_CENTER = prs.center
                            AND art_inv.PAYREQ_SPEC_ID = prs.id
                            AND art_inv.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_inv.REF_TYPE IN ('INVOICE')
                        JOIN
                            fernwood.invoice_lines_mt ivl
                        ON
                            ivl.center = art_inv.ref_center
                            AND ivl.id = art_inv.ref_id
                            --AND ivl.subid = art_inv.ref_subid
                        JOIN
                            account_trans act
                        ON
                            act.center = ivl.account_trans_center
                            AND act.id = ivl.account_trans_id
                            AND act.subid = ivl.account_trans_subid
                        LEFT JOIN
                            fernwood.products prod
                        ON
                            prod.center = ivl.productcenter
                            AND prod.id = ivl.productid
                        JOIN
                            fernwood.product_account_configurations pac
                        ON
                            pac.id = prod.product_account_config_id
                        UNION ALL
                        SELECT -- Get credit note type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            prod.name                             AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            act.text                              AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_inv.amount                        AS "Cost Center Amount",
                            -cnl.total_amount                      AS "Cost Center Amount-new",
                            pac.sales_account_globalid            AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            act.amount                            AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"                              
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) --Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_inv
                        ON
                            art_inv.PAYREQ_SPEC_CENTER = prs.center
                            AND art_inv.PAYREQ_SPEC_ID = prs.id
                            AND art_inv.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_inv.REF_TYPE IN ('CREDIT_NOTE')
                        JOIN
                            fernwood.credit_note_lines_mt cnl
                        ON
                            cnl.center = art_inv.ref_center
                            AND cnl.id = art_inv.ref_id
                            --    AND cnl.subid = art_inv.ref_subid
                        JOIN
                            account_trans act
                        ON
                            act.center = cnl.account_trans_center
                            AND act.id = cnl.account_trans_id
                            AND act.subid = cnl.account_trans_subid
                        LEFT JOIN
                            fernwood.products prod
                        ON
                            prod.center = cnl.productcenter
                            AND prod.id = cnl.productid
                        JOIN
                            fernwood.product_account_configurations pac
                        ON
                            pac.id = prod.product_account_config_id
                        UNION ALL
                        SELECT -- Get installment plan type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            'INSTALLMENT'                         AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            art_at.text                           AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_at.amount                         AS "Cost Center Amount",
                            -art_at.amount                         AS "Cost Center Amount-new",
                            'INSTALLMENT_PLAN_INC'                AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            NULL                                  AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"                              
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) --Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_at
                        ON
                            art_at.PAYREQ_SPEC_CENTER = prs.center
                            AND art_at.PAYREQ_SPEC_ID = prs.id
                            AND art_at.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_at.REF_TYPE IN ('ACCOUNT_TRANS')
                            AND art_at.COLLECTED = 5 --Transfer InstallmentToPayment Account
                            AND art_at.amount < 0
                    ) A
                        JOIN 
                            params 
                            ON params.id = A."Scope"                       
                    WHERE 
                        --A.customercenter = 101
                        --A."ExerpId" IN ('101p19016')--101p253')--('101p3050')--, '105p1000','401p1707',  '401p1305')
                        --AND 
                        A."Club (CHANGE TO CLUB NAME)" = :center 
                        AND 
                        A."Payment Request date and Time" BETWEEN FROM_DATE AND TO_DATE
                GROUP BY
                        A."ExerpId",
                        A."Amount including VAT (Exerp)",
                        A."Payment Request date and Time",
                        A."Payment request Reference" ,
                        A."Payway Customer Number"
                )T
JOIN
                (
                SELECT
                        *
                FROM                        
                        (
                        SELECT -- Get invoice type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            prod.name                             AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            act.text                              AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_inv.amount                        AS "Cost Center Amount",
                            ivl.total_amount                      AS "Cost Center Amount-new",
                            pac.sales_account_globalid            AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            act.amount                            AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) -- Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_inv
                        ON
                            art_inv.PAYREQ_SPEC_CENTER = prs.center
                            AND art_inv.PAYREQ_SPEC_ID = prs.id
                            AND art_inv.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_inv.REF_TYPE IN ('INVOICE')
                        JOIN
                            fernwood.invoice_lines_mt ivl
                        ON
                            ivl.center = art_inv.ref_center
                            AND ivl.id = art_inv.ref_id
                            --AND ivl.subid = art_inv.ref_subid
                        JOIN
                            account_trans act
                        ON
                            act.center = ivl.account_trans_center
                            AND act.id = ivl.account_trans_id
                            AND act.subid = ivl.account_trans_subid
                        LEFT JOIN
                            fernwood.products prod
                        ON
                            prod.center = ivl.productcenter
                            AND prod.id = ivl.productid
                        JOIN
                            fernwood.product_account_configurations pac
                        ON
                            pac.id = prod.product_account_config_id
                        UNION ALL
                        SELECT -- Get credit note type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            prod.name                             AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            act.text                              AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_inv.amount                        AS "Cost Center Amount",
                            -cnl.total_amount                      AS "Cost Center Amount-new",
                            pac.sales_account_globalid            AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            act.amount                            AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"                            
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) --Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_inv
                        ON
                            art_inv.PAYREQ_SPEC_CENTER = prs.center
                            AND art_inv.PAYREQ_SPEC_ID = prs.id
                            AND art_inv.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_inv.REF_TYPE IN ('CREDIT_NOTE')
                        JOIN
                            fernwood.credit_note_lines_mt cnl
                        ON
                            cnl.center = art_inv.ref_center
                            AND cnl.id = art_inv.ref_id
                            --    AND cnl.subid = art_inv.ref_subid
                        JOIN
                            account_trans act
                        ON
                            act.center = cnl.account_trans_center
                            AND act.id = cnl.account_trans_id
                            AND act.subid = cnl.account_trans_subid
                        LEFT JOIN
                            fernwood.products prod
                        ON
                            prod.center = cnl.productcenter
                            AND prod.id = cnl.productid
                        JOIN
                            fernwood.product_account_configurations pac
                        ON
                            pac.id = prod.product_account_config_id
                        UNION ALL
                        SELECT -- Get installment plan type transactions associcated with payment requests
                            ar.customercenter||'p'||ar.customerid AS "ExerpId",
                            pr.req_amount                         AS "Amount including VAT (Exerp)",
                            pr.request_type                       AS "Request Type (MISSING DECODE)",
                            ar.customercenter                     AS "Club (CHANGE TO CLUB NAME)",
                            'INSTALLMENT'                         AS "Product Name",
                            prs.included_overdue_amount           AS "Overdue Amount Included",
                            art_at.text                           AS "Transaction Text",
                            longtodatec(pr.entry_time,pr.center)  AS "Payment Request date and Time",
                            --art_at.amount                         AS "Cost Center Amount",
                            -art_at.amount                         AS "Cost Center Amount-new",
                            'INSTALLMENT_PLAN_INC'                AS "Cost Center",
                            prs.ref                               AS "Payment request Reference" ,
                            pag.ref                               AS "Payway Customer Number",
                            NULL                                  AS "Transaction Line Amount excluding VAT",
                            ar.customercenter                     AS "Scope"                            
                        FROM -- Go over all payment requests
                            fernwood.payment_requests pr
                        JOIN -- Join with account receiveables to filter on member ID
                            fernwood.account_receivables ar
                        ON
                            ar.center = pr.center
                            AND ar.id = pr.id
                            AND ar_type = 4
                            AND pr.STATE IN (3,4) --Only include payment requests in state Done / Done manual
                        JOIN -- Join payment request specifications to get additional info on the payment request
                            fernwood.payment_request_specifications prs
                        ON
                            prs.center = pr.inv_coll_center
                            AND prs.id = pr.inv_coll_id
                            AND prs.subid = pr.inv_coll_subid
                        JOIN -- Join with payment agreement to get Payway Customer Number
                            fernwood.payment_agreements pag
                        ON
                            pag.center = pr.center
                            AND pag.id = pr.id
                            AND pag.subid = pr.agr_subid
                        JOIN -- Join with Account Receivable Transaction to find invoice lines associcated with payment request
                            AR_TRANS art_at
                        ON
                            art_at.PAYREQ_SPEC_CENTER = prs.center
                            AND art_at.PAYREQ_SPEC_ID = prs.id
                            AND art_at.PAYREQ_SPEC_SUBID = prs.subid
                            AND art_at.REF_TYPE IN ('ACCOUNT_TRANS')
                            AND art_at.COLLECTED = 5 --Transfer InstallmentToPayment Account
                            AND art_at.amount < 0 --To avoid including the
                        ) T1
                        JOIN 
                            params 
                            ON params.id = T1."Scope"                               
                        WHERE 
                        --A.customercenter = 101
                        --A."ExerpId" IN ('101p19016')--101p253')--('101p3050')--, '105p1000','401p1707',  '401p1305')
                        --AND 
                        T1."Club (CHANGE TO CLUB NAME)" = :center 
                        AND 
                        T1."Payment Request date and Time" BETWEEN FROM_DATE AND TO_DATE
                )T2
                ON T2."ExerpId" = T."ExerpId"
                AND T2."Amount including VAT (Exerp)" = T."Amount including VAT (Exerp)"
                AND T2."Payment request Reference" = T."Payment request Reference"                        
ORDER BY 1,6                                                     

