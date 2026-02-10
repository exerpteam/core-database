-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/DATA-124
WITH
    res AS ( 
    SELECT
        art.center as account_center,
        art.id as account_id,
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
        END                                                     AS "Payment Request State"
        , art.center||'ar'||art.id||'art'||art.subid            AS "Transaction ID"
        , pr.req_date                                           AS "Transaction Date"
        , pr.req_delivery
        , COALESCE(sac.name,sac_cl.name)                        AS "Ledger Group"
        , COALESCE(sac.external_id,sac_cl.external_id)          AS "Ledger Group Code"
        , acc.name                                              AS "Account for Manual Operations"
        , CASE
            WHEN prod.ptype IN (1,4)
            THEN 'Retail'
            WHEN prod.ptype IS NOT NULL
            AND prod.ptype NOT IN (1,4)
            THEN 'Fees'
            WHEN art.ref_type = 'OVERDUE_AMOUNT'
            THEN 'Overdue Amount'
        END                            AS "Revenue Type",
        COALESCE(prod.name,art.text)   AS "Item Description",
        pr.xfr_date                    AS "Payment Collected date",
        COALESCE(-1*cl.total_amount,il.total_amount,-1*art.amount) AS "Total Requested Amount",
        CASE WHEN pr.state NOT IN (4,18)
             THEN COALESCE(-1*cl.total_amount,il.total_amount,-1*art.amount)
             ELSE 0
        END "Total Collected Amount",
        il.person_center||'p'||il.person_id as member_id,        
        CASE
            WHEN art.ref_type = 'INVOICE'
            THEN il.center||'inv'||il.id||'ln'||il.subid
            WHEN art.ref_type = 'CREDIT_NOTE'
            THEN cl.center||'cred'||cl.id||'ln'||cl.subid
        END                                                                                 AS "Sales Line ID",
        COALESCE(cl.quantity,il.quantity)                                                   AS "Total Quantity",
        COALESCE(-1*cl.total_amount,il.total_amount,-1*art.amount)                          AS "Total Sale Amount",
        COALESCE(-1*cl.net_amount,il.net_amount,-1*art.amount)                              AS "Total Net Amount",
        COALESCE( -1*(cl.total_amount - cl.net_amount), il.total_amount - il.net_amount,0)  AS "Total Tax Amount",
        ROUND(COALESCE(vl_cl.rate, vl.rate ),2)                                             AS "Tax Rate",
        pr.agr_subid
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
      pr.req_delivery::VARCHAR IN (:Payment_export_id)
      AND pr.state != 8  --- cancelled
      AND pr.req_amount != 0
    )
SELECT
        c.name                                                        AS "Club",
        c.id                                                          AS "Club Number",
        c.external_id                                                 AS "Club Code",
        cp.external_id                                                AS "Membership Number",
        res.member_id                                                 AS "Member ID",
        cp.center||'p'||cp.id                                         AS "Payer ID",
        res.req_delivery                                              AS "Payment Export File",
        res."Bank Run ID",
        res."Bank Run Type",
        res."Payment Request State",
        res."Transaction ID",
        res."Transaction Date",
        res."Ledger Group",
        res."Ledger Group Code",
        res."Account for Manual Operations",
        res."Revenue Type",
        res."Item Description",
        res."Payment Collected date",
        res."Total Requested Amount",
        res."Total Collected Amount",
        res."Sales Line ID",
        res."Total Quantity",
        res."Total Sale Amount",
        res."Total Net Amount",
        res."Total Tax Amount",
        res."Tax Rate",
         CASE
            WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
            THEN  'Credit Card'
            WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157
                              , 158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189
                              , 191,192
                              , 201)
            THEN 'Direct Debit'
            WHEN ch.ctype IN (8,16,32,128,129,131,132,133,134,135,136,139,142,147,149,151,154
                              , 161,166
                              , 170,171,174,195)
            THEN 'Invoice'
        END                   AS "Tender Type",
        COALESCE(ch.name)     AS "Merchant Bank"
    FROM
        res
    JOIN
        account_receivables ar
    ON
        ar.center = res.account_center
    AND ar.id = res.account_id
    AND ar.ar_type in (1,4)
    LEFT JOIN
        account_receivables arpay
    ON
        ar.customercenter = arpay.customercenter
    AND ar.customerid = arpay.customerid
    AND arpay.ar_type = 4
    JOIN
        persons p
    ON
        p.center = arpay.customercenter
    AND p.id = arpay.customerid
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
        payment_agreements pag
    ON
        pag.center = arpay.center
    AND pag.id = arpay.id
    AND pag.subid = res.agr_subid
    LEFT JOIN
        clearinghouses ch
    ON
        ch.id = pag.clearinghouse