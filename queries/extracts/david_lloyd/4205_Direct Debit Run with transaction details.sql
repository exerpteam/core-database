-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , $$from_date$$:: DATE                                             AS from_date
        , $$to_date$$:: DATE                                             AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , res AS
    ( SELECT
        pr.center||'pr'||pr.id||'id'||pr.subid AS "Bank Run ID"
        , CASE pr.REQUEST_TYPE
            WHEN 1
            THEN 'Billing'
            WHEN 5
            THEN 'Refund'
            WHEN 6
            THEN 'Rebilling'
        END AS "Bank Run Type"
        ,CASE pr.STATE 
            WHEN 1 
            THEN 'New' 
            WHEN 2 
            THEN 'Sent' 
            WHEN 3 
            THEN 'Done' 
            WHEN 4 
            THEN 'Done, manual' 
            WHEN 5 
            THEN 'Rejected, clearinghouse' 
            WHEN 6 
            THEN 'Rejected, bank' 
            WHEN 7 
            THEN 'Rejected, debtor' 
            WHEN 8 
            THEN 'Cancelled' 
            WHEN 10 
            THEN 'Reversed, new' 
            WHEN 11 
            THEN 'Reversed , sent' 
            WHEN 12 
            THEN 'Failed, not creditor' 
            WHEN 13 
            THEN 'Reversed, rejected' 
            WHEN 14 
            THEN 'Reversed, confirmed' 
            WHEN 17 
            THEN 'Failed, payment revoked' 
            WHEN 18 
            THEN 'Done Partial' 
            WHEN 19 
            THEN 'Failed, Unsupported' 
            WHEN 20 
            THEN 'Require approval' 
            WHEN 21 
            THEN 'Fail, debt case exists' 
            WHEN 22 
            THEN 'Failed, timed out' 
            ELSE 'Undefined' 
        END                                          AS payment_request_state
        , c.name                                                        AS "Club"
        , c.id                                                          AS "Club Number"
        , c.external_id                                                 AS "Club Code"
        , cp.external_id                                                AS "Membership Number"
        , p.center||'p'||p.id                                           AS "Person Key"
        , cp.center||'p'||cp.id                                         AS "Current Person Key"
        , art.center||'ar'||art.id||'art'||art.subid                    AS "Transaction ID"
        , pr.req_date                                                   AS "Transaction Date"
        , COALESCE(sac.name,sac_cl.name, acc.name)                      AS "Ledger Group"
        , COALESCE(sac.external_id,sac_cl.external_id, acc.external_id) AS "Ledger Group Code"
        , CASE
            WHEN prod.ptype IN (1,4)
                /**/
            THEN 'Retail'
            WHEN prod.ptype IS NOT NULL
            AND prod.ptype NOT IN (1,4)
            THEN 'Fees'
            WHEN art.ref_type = 'OVERDUE_AMOUNT'
            THEN 'Overdue Amount'
        END                            AS "Revenue Type"
        , COALESCE(prod.name,art.text) AS "Item Description"
        , CASE
                -- note: these codes are retrieved from ClearingHousePluginType.java in the
                -- Exerp
                -- codebase -- 2023-10-30
            WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
            THEN
                CASE pag.credit_card_type
                    WHEN 1
                    THEN 'VISA'
                    WHEN 2
                    THEN 'MasterCard'
                    WHEN 3
                    THEN 'Maestro'
                    WHEN 4
                    THEN 'Dankort'
                    WHEN 5
                    THEN 'AmericanExpress'
                    WHEN 6
                    THEN 'DinersClub'
                    WHEN 7
                    THEN 'JcB'
                    WHEN 8
                    THEN 'Sparbanken'
                    WHEN 9
                    THEN 'Shell'
                    WHEN 10
                    THEN 'NorskHydroUnoX'
                    WHEN 11
                    THEN 'OKQ8'
                    WHEN 12
                    THEN 'Preem'
                    WHEN 13
                    THEN 'Statoil'
                    WHEN 14
                    THEN 'StatoilRoutex'
                    WHEN 15
                    THEN 'Volvo'
                    WHEN 16
                    THEN 'VISAElectron'
                    WHEN 17
                    THEN 'Visa Credit'
                    WHEN 18
                    THEN 'BT Test Host'
                    WHEN 19
                    THEN 'Time'
                    WHEN 20
                    THEN 'Solo'
                    WHEN 21
                    THEN 'Laser'
                    WHEN 22
                    THEN 'LTF'
                    WHEN 23
                    THEN 'CAF'
                    WHEN 24
                    THEN 'Creation'
                    WHEN 25
                    THEN 'Clydesdale'
                    WHEN 26
                    THEN 'BHS Gold'
                    WHEN 27
                    THEN 'Mothercare Card'
                    WHEN 28
                    THEN 'Burton Menswear'
                    WHEN 29
                    THEN 'BA AirPlus'
                    WHEN 30
                    THEN 'EDC/Maestro'
                    WHEN 31
                    THEN 'Visa Debit'
                    WHEN 32
                    THEN 'Postcard'
                    WHEN 33
                    THEN 'Jelmoli Bonus Card'
                    WHEN 34
                    THEN 'EC/Bankomat'
                    WHEN 35
                    THEN 'V PAY'
                    WHEN 36
                    THEN 'Beeptify'
                    WHEN 37
                    THEN 'External device'
                    WHEN 38
                    THEN 'Interac'
                    WHEN 39
                    THEN 'Discover'
                    WHEN 40
                    THEN 'UnionPay'
                    WHEN 41
                    THEN 'AllStar'
                    WHEN 42
                    THEN 'Arcadia Group Card'
                    WHEN 43
                    THEN 'FCUK card'
                    WHEN 44
                    THEN 'MasterCard Debit'
                    WHEN 45
                    THEN 'IKEA Home card'
                    WHEN 46
                    THEN 'HFC Store card'
                    WHEN 47
                    THEN 'Accel'
                    WHEN 48
                    THEN 'AFFN'
                    WHEN 49
                    THEN 'Alipay'
                    WHEN 50
                    THEN 'BCMC'
                    WHEN 51
                    THEN 'CarnetDebit'
                    WHEN 52
                    THEN 'CarteBancaire'
                    WHEN 53
                    THEN 'Cabal'
                    WHEN 54
                    THEN 'Codensa'
                    WHEN 55
                    THEN 'CU24'
                    WHEN 56
                    THEN 'eftpos_australia'
                    WHEN 57
                    THEN 'elocredit'
                    WHEN 58
                    THEN 'Interlink'
                    WHEN 59
                    THEN 'Narania'
                    WHEN 60
                    THEN 'NYCE'
                    WHEN 61
                    THEN 'Pulse'
                    WHEN 62
                    THEN 'shazam_pinless'
                    WHEN 63
                    THEN 'Star'
                    WHEN 64
                    THEN 'Vias'
                    WHEN 65
                    THEN 'Warehouse'
                    WHEN 66
                    THEN 'mccredit'
                    WHEN 67
                    THEN 'mcstandardcredit'
                    WHEN 68
                    THEN 'mcstandarddebit'
                    WHEN 69
                    THEN 'mcpremiumcredit'
                    WHEN 70
                    THEN 'mcpremiumdebit'
                    WHEN 71
                    THEN 'mcsuperpremiumcredit'
                    WHEN 72
                    THEN 'mcsuperpremiumdebit'
                    WHEN 73
                    THEN 'mccommercialcredit'
                    WHEN 74
                    THEN 'mccommercialdebit'
                    WHEN 75
                    THEN 'mccommercialpremiumcredit'
                    WHEN 76
                    THEN 'mccommercialpremiumdebit'
                    WHEN 77
                    THEN 'mccorporatecredit'
                    WHEN 78
                    THEN 'mccorporatedebit'
                    WHEN 79
                    THEN 'mcpurchasingcredit'
                    WHEN 80
                    THEN 'mcpurchasingdebit'
                    WHEN 81
                    THEN 'mcfleetcredit'
                    WHEN 82
                    THEN 'mcfleetdebit'
                    WHEN 83
                    THEN 'mcpro'
                    WHEN 84
                    THEN 'mc_applepay'
                    WHEN 85
                    THEN 'mc_androidpay'
                    WHEN 86
                    THEN 'bijcard'
                    WHEN 87
                    THEN 'visastandardcredit'
                    WHEN 88
                    THEN 'visastandarddebit'
                    WHEN 89
                    THEN 'visapremiumcredit'
                    WHEN 90
                    THEN 'visapremiumdebit'
                    WHEN 91
                    THEN 'visasuperpremiumcredit'
                    WHEN 92
                    THEN 'visasuperpremiumdebit'
                    WHEN 93
                    THEN 'visacommercialcredit'
                    WHEN 94
                    THEN 'visacommercialdebit'
                    WHEN 95
                    THEN 'visacommercialpremiumcredit'
                    WHEN 96
                    THEN 'visacommercialpremiumdebit'
                    WHEN 97
                    THEN 'visacommercialsuperpremiumcredit'
                    WHEN 98
                    THEN 'visacommercialsuperpremiumdebit'
                    WHEN 99
                    THEN 'visacorporatecredit'
                    WHEN 100
                    THEN 'visacorporatedebit'
                    WHEN 101
                    THEN 'visapurchasingcredit'
                    WHEN 102
                    THEN 'visapurchasingdebit'
                    WHEN 103
                    THEN 'visafleetcredit'
                    WHEN 104
                    THEN 'visafleetdebit'
                    WHEN 105
                    THEN 'visadankort'
                    WHEN 106
                    THEN 'visapropreitary'
                    WHEN 107
                    THEN 'visa_applepay'
                    WHEN 108
                    THEN 'visa_androidpay'
                    WHEN 109
                    THEN 'amex_applepay'
                    WHEN 110
                    THEN 'boletobancario_santander'
                    WHEN 111
                    THEN 'diners_applepay'
                    WHEN 112
                    THEN 'directEbanking'
                    WHEN 113
                    THEN 'discover_applepay'
                    WHEN 114
                    THEN 'dotpay'
                    WHEN 115
                    THEN 'idealbn'
                    WHEN 116
                    THEN 'idealing'
                    WHEN 117
                    THEN 'idealrabobank'
                    WHEN 118
                    THEN 'paypal'
                    WHEN 119
                    THEN 'sepadirectdebit_authcap'
                    WHEN 120
                    THEN 'depadirectdebit_received'
                    WHEN 121
                    THEN 'cupcredit'
                    WHEN 122
                    THEN 'cupdebit'
                    WHEN 123
                    THEN 'Card on file'
                    WHEN 124
                    THEN 'MADA'
                    WHEN 125
                    THEN 'APPLEPAY'
                    WHEN 126
                    THEN 'PAYWITHGOOGLE'
                    WHEN 127
                    THEN 'TWINT'
                    WHEN 128
                    THEN 'ach'
                    WHEN 129
                    THEN 'paybybank'
                    WHEN 1000
                    THEN 'Other'
                    ELSE credit_card_type::TEXT
                END
            WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157
                              , 158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189
                              , 191,192
                              , 201)
            THEN 'Direct Debit'
            WHEN ch.ctype IN (8,16,32,128,129,131,132,133,134,135,136,139,142,147,149,151,154
                              , 161,166
                              , 170,171,174,195)
            THEN 'INVOICE'
        END           AS "Tender Type"
        , ch.name     AS "Merchant Bank"
        , NULL        AS "Transaction Type"
        , pr.xfr_date AS "Payment Collected date"
        , CASE
            WHEN ROW_NUMBER() over (
                                PARTITION BY
                                    pr.center||'pr'||pr.id||'id'||pr.subid
                                ORDER BY
                                    art.subid ASC ) = 1
            THEN pr.req_amount
            ELSE NULL
        END AS "Total Requested Amount"
        , CASE
            WHEN ROW_NUMBER() over (
                                PARTITION BY
                                    pr.center||'pr'||pr.id||'id'||pr.subid
                                ORDER BY
                                    art.subid ASC ) = 1
            THEN
                CASE
                    WHEN pr.state IN(4,18)
                    THEN 0
                    ELSE pr.xfr_amount
                END
            ELSE NULL
        END AS "Total Collected Amount"
        , CASE
            WHEN ROW_NUMBER() over (
                                PARTITION BY
                                    pr.center||'pr'||pr.id||'id'||pr.subid
                                ORDER BY
                                    art.subid ASC ) = 1
            THEN
                CASE
                    WHEN pr.state IN(4,18)
                    THEN 0
                    ELSE pr.xfr_amount
                END
            ELSE NULL
        END
        /*art.amount*/
        AS "Transaction Amount"
        , CASE
            WHEN art.ref_type = 'INVOICE'
            THEN il.center||'inv'||il.id||'ln'||il.subid
            WHEN art.ref_type = 'CREDIT_NOTE'
            THEN cl.center||'cred'||cl.id||'ln'||cl.subid
        END                                                                       AS "Sales Line ID"
        ,COALESCE(cl.quantity,il.quantity)                                       AS "Total Quantity"
        , COALESCE(-1*cl.total_amount,il.total_amount,-1*art.amount)          AS "Total Sale Amount"
        , COALESCE(-1*cl.net_amount,il.net_amount,-1*art.amount)               AS "Total Net Amount"
        ,COALESCE( -1*(cl.total_amount - cl.net_amount), il.total_amount - il.net_amount,0) AS
        "Total Tax Amount"
        , COALESCE(vl_cl.rate, vl.rate )AS "Tax Rate"
    FROM
        payment_requests pr
    JOIN
        ar_trans art
    ON
        pr.inv_coll_center = art.payreq_spec_center
    AND pr.inv_coll_id = art.payreq_spec_id
    AND pr.inv_coll_subid = art.payreq_spec_subid
    AND art.collected = 1
    JOIN
        payment_request_specifications prs
    ON
        prs.center = art.payreq_spec_center
    AND prs.id = art.payreq_spec_id
    AND prs.subid = art.payreq_spec_subid
    JOIN
        account_receivables ar
    ON
        ar.center =art.center
    AND ar.id = art.id
    AND ar.ar_type = 4
    JOIN
        payment_accounts pac
    ON
        pac.center = art.center
    AND pac.id = art.id
    JOIN
        payment_agreements pag
    ON
        pag.center = ar.center
    AND pag.id = ar.id
    AND pag.subid = pr.agr_subid
    JOIN
        clearinghouses ch
    ON
        ch.id = pag.clearinghouse
    LEFT JOIN
        credit_note_lines_mt cl
    ON
        cl.center = art.ref_center
    AND cl.id = art.ref_id
    AND art.ref_type = 'CREDIT_NOTE'
    LEFT JOIN
        invoice_lines_mt il
    ON
        il.center = art.ref_center
    AND il.id = art.ref_id
    AND art.ref_type = 'INVOICE'
    LEFT JOIN
        invoicelines_vat_at_link vl
    ON
        vl.invoiceline_center = il.center
    AND vl.invoiceline_id = il.id
    AND vl.invoiceline_subid = il.subid
    JOIN
        persons p
    ON
        p.center = ar.customercenter
    AND p.id = ar.customerid
    LEFT JOIN
        products prod
    ON
        prod.center = il.productcenter
    AND prod.id = il.productid
    LEFT JOIN
        product_account_configurations prac
    ON
        prac.id = prod.product_account_config_id
    LEFT JOIN
        accounts sac
    ON
        sac.globalid = prac.sales_account_globalid
    AND sac.center = prod.center
    LEFT JOIN
        products prod_cl
    ON
        prod_cl.center = cl.productcenter
    AND prod_cl.id = cl.productid
    LEFT JOIN
        product_account_configurations prac_cl
    ON
        prac_cl.id = prod_cl.product_account_config_id
    LEFT JOIN
        accounts sac_cl
    ON
        sac_cl.globalid = prac_cl.sales_account_globalid
    AND sac_cl.center = prod_cl.center
    LEFT JOIN
        credit_note_line_vat_at_link vl_cl
    ON
        vl_cl.credit_note_line_center = cl.center
    AND vl_cl.credit_note_line_id = cl.id
    AND vl_cl.credit_note_line_subid= cl.subid
    JOIN
        params
    ON
        params.center = pr.center
    JOIN
        persons cp
    ON
        cp.center = p.transfers_current_prs_center
    AND cp.id = p.transfers_current_prs_id
    JOIN
        centers c
    ON
        c.id = cp.center
    LEFT JOIN
        account_trans act
    ON
        act.center = art.ref_center
    AND act.id = art.ref_id
    AND act.subid = art.ref_subid
    AND art.ref_type = 'ACCOUNT_TRANS'
    LEFT JOIN
        accounts acc
    ON
        acc.center = act.credit_accountcenter
    AND acc.id = act.credit_accountid
    WHERE
        pr.req_date BETWEEN params.from_date AND params.to_date
    AND pr.state != 8
    AND pr.req_amount != 0
    )
    , tst_reconcile AS
    ( -- compare to Billing batch report tst, should be equal
    SELECT
        COUNT(*)
        , SUM("Total Requested Amount")
        , SUM("Total Collected Amount")
    FROM
        res
    )
    , tst_duplicates AS
    ( SELECT
        *
    FROM
        ( SELECT
            *
            , SUM( -- each sales line should only appear once per payment requet
            CASE
                WHEN "Sales Line ID" IS NOT NULL
                THEN 1
                ELSE 0
            END) over (
                   PARTITION BY
                       "Bank Run ID"
                       , "Sales Line ID") AS sales_pr_dup
            , SUM( -- each sales line should only appear once per payment requet
            CASE
                WHEN "Sales Line ID" IS NOT NULL
                AND "Bank Run Type" = 'Billing'
                THEN 1
                ELSE 0
            END) over (
                   PARTITION BY
                       "Sales Line ID") AS sales_billing_pr_dup
        FROM
            res)
    WHERE
        sales_pr_dup > 1
    OR  sales_billing_pr_dup > 1
    )
SELECT
    *
FROM
    res