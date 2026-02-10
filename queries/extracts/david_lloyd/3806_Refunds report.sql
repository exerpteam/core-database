-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10769
/*This extract aims to export all the 'refunds' that took place in a period. hese refunds should
only include
money that 'left' exerp - meaning money that was actually paid out to the member, and not credits
to a member's account.
For DLL, this includes front dest refunds and payment request refunds.
*/
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                         AS center
        , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                 AS from_date_long
        , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long
        , $$from_date$$::DATE                                            AS from_date
        , $$to_date$$::DATE                                            AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , crt_api_refunds AS
    ( SELECT
        c.name                                                        AS "Scope"
        ,c.external_id                                                AS "Site ID"
        ,cn.text                                                      AS "Reason"
        ,cn.coment                                                    AS "Cancel Reason"
        ,longtodatec(COALESCE(crt.transtime,cn.entry_time),cn.center) AS "Datetime"
        ,p.external_id "Member External ID"
        ,CASE
            WHEN p.center IS NOT NULL
            THEN p.center||'p'||p.id
            ELSE NULL
        END                                          AS "MemberKey"
        ,p.fullname                                  AS "MemberName"
        ,cnl.center||'cred'||cn.id||'cnl'||cnl.subid AS "CreditNoteLineKey"
        ,cnl.center||'cred'||cn.id||'cnl'||cnl.subid AS "LineHeader"
        ,cn.employee_center||'emp'||cn.employee_id   AS "EmployeeKey"
        ,cnl.quantity                                AS "Quantity"
        ,pr.name                                     AS "ProductName"
        ,pg.name                                     AS "ProductGroupName"
        ,act_debit_acc.name                          AS "AccountName"
        ,act_debit_acc.external_id                   AS "AccountExternalID"
        ,CASE
            WHEN crt.id IS NULL
            THEN 'API'
            ELSE
                CASE crt.CRTTYPE
                    WHEN 1
                    THEN 'CASH'
                    WHEN 2
                    THEN 'CHANGE'
                    WHEN 3
                    THEN 'RETURN ON CREDIT'
                    WHEN 4
                    THEN 'PAYOUT CASH'
                    WHEN 5
                    THEN 'PAID BY CASH AR ACCOUNT'
                    WHEN 6
                    THEN 'DEBIT CARD'
                    WHEN 7
                    THEN 'CREDIT CARD'
                    WHEN 8
                    THEN 'DEBIT OR CREDIT CARD'
                    WHEN 9
                    THEN 'GIFT CARD'
                    WHEN 10
                    THEN 'CASH ADJUSTMENT'
                    WHEN 11
                    THEN 'CASH TRANSFER'
                    WHEN 12
                    THEN 'PAYMENT AR'
                    WHEN 13
                    THEN 'CONFIG PAYMENT METHOD'
                    WHEN 14
                    THEN 'CASH REGISTER PAYOUT'
                    WHEN 15
                    THEN 'CREDIT CARD ADJUSTMENT'
                    WHEN 16
                    THEN 'CLOSING CASH ADJUST'
                    WHEN 17
                    THEN 'VOUCHER'
                    WHEN 18
                    THEN 'PAYOUT CREDIT CARD'
                    WHEN 19
                    THEN 'TRANSFER BETWEEN REGISTERS'
                    WHEN 20
                    THEN 'CLOSING CREDIT CARD ADJ'
                    WHEN 21
                    THEN 'TRANSFER BACK CASH COINS'
                    WHEN 22
                    THEN 'INSTALLMENT PLAN'
                    WHEN 100
                    THEN 'INITIAL CASH'
                    WHEN 101
                    THEN 'MANUAL'
                END
        END                                             AS "Tender"
        ,ROUND(COALESCE(crt.amount,cnl.total_amount),2) AS "Tender Amount"
    FROM
        params
    JOIN
        credit_notes cn
    ON
        cn.center = params.center
    JOIN
        credit_note_lines_mt cnl
    ON
        cnl.center = cn.center
    AND cnl.id = cn.id
    LEFT JOIN
        cashregistertransactions crt
    ON
        crt.paysessionid = cn.paysessionid
    AND
        (
            (
                crt.customercenter = cn.payer_center
            AND crt.customerid = cn.payer_id)
        OR  crt.customercenter IS NULL)
    LEFT JOIN
        centers c
    ON
        c.id = cn.center
    LEFT JOIN
        persons p
    ON
        cn.payer_center = p.center
    AND cn.payer_id = p.id
    JOIN
        products pr
    ON
        pr.center = cnl.productcenter
    AND pr.id = cnl.productid
    JOIN
        product_group pg
    ON
        pg.id = pr.primary_product_group_id
    JOIN
        product_account_configurations pac
    ON
        pac.id = pr.product_account_config_id
    JOIN
        accounts act_debit_acc
    ON
        act_debit_acc.center = pr.center
    AND act_debit_acc.globalid = pac.refund_account_globalid
    WHERE
        cn.entry_time BETWEEN params.from_date_long AND params.to_date_long
    AND
        (
            crt.id IS NOT NULL
        OR
            (
                cn.employee_center = 100
            AND cn.employee_id = 451))
    )
    ,pr_refunds AS
    (
    /*This section exports all the 'reund' type payment requests
    we trak back from the PR to the AR transactions, and then further to the Credit Note (if
    there is
    one)
    DLL need to know which GL account the money came out of, which is available on the */
    SELECT
        c.name         AS "Scope"
        ,c.external_id AS "Site ID"
        ,art.text      AS "Reason"
        ,cn.coment     AS "Cancel Reason"
        ,pr.due_date   AS "Datetime"
        ,p.external_id "Member External ID"
        ,CASE
            WHEN p.center IS NOT NULL
            THEN p.center||'p'||p.id
            ELSE NULL
        END                                                                           AS "MemberKey"
        ,p.fullname                                                                  AS "MemberName"
        ,cnl.center||'cred'||cn.id||'cnl'||cnl.subid                          AS "CreditNoteLineKey"
        ,pr.center||'ar'||pr.id||'req'||pr.SUBID                                     AS "LineHeader"
        ,art.employeecenter||'emp'||art.employeeid                                  AS "EmployeeKey"
        ,COALESCE(cnl.quantity,il.quantity)                                            AS "Quantity"
        ,COALESCE(cnl_prod.name,il_prod.name)                                       AS "ProductName"
        ,COALESCE(cnl_pg.name,il_pg.name)                                      AS "ProductGroupName"
        ,COALESCE(cnl_ref_acc.name,act_debit_acc.name,il_sale_acc.name)             AS "AccountName"
        ,COALESCE(cnl_ref_acc.external_id,act_debit_acc.external_id,il_sale_acc.external_id) AS 
        "AccountExternalID"
        ,'Direct Debit'                                                    AS "Tender"
        ,ROUND(COALESCE(cnl.total_amount,il.total_amount*-1,art.amount),2) AS "Tender Amount"
    FROM
        params
    JOIN
        payment_requests pr
    ON
        pr.center = params.center
    JOIN
        account_receivables ar
    ON
        ar.center = pr.center
    AND ar.id = pr.id
    JOIN
        persons p
    ON
        p.center = ar.customercenter
    AND p.id = ar.customerid
    JOIN
        ar_trans art
    ON
        art.payreq_spec_center = pr.inv_coll_center
    AND art.payreq_spec_id = pr.inv_coll_id
    AND art.payreq_spec_subid = pr.inv_coll_subid
    AND art.match_info IS NULL
    LEFT JOIN
        credit_notes cn
    ON
        cn.center = art.ref_center
    AND cn.id = art.ref_id
    AND art.ref_type = 'CREDIT_NOTE'
    LEFT JOIN
        credit_note_lines_mt cnl
    ON
        cnl.center = art.ref_center
    AND cnl.id = art.ref_id
    AND art.ref_type = 'CREDIT_NOTE'
    LEFT JOIN
        products cnl_prod
    ON
        cnl_prod.center = cnl.productcenter
    AND cnl_prod.id = cnl.productid
    LEFT JOIN
        product_group cnl_pg
    ON
        cnl_pg.id = cnl_prod.primary_product_group_id
    LEFT JOIN
        centers c
    ON
        c.id = p.center
    LEFT JOIN
        account_trans act
    ON
        art.ref_center = act.center
    AND art.ref_id = act.id
    AND art.ref_subid = act.subid
    AND art.ref_type = 'ACCOUNT_TRANS'
    LEFT JOIN
        accounts act_debit_acc
    ON
        act.debit_accountcenter = act_debit_acc.center
    AND act.debit_accountid = act_debit_acc.id
    LEFT JOIN
        product_account_configurations cnl_pac
    ON
        cnl_pac.id = cnl_prod.product_account_config_id
    LEFT JOIN
        accounts cnl_ref_acc
    ON
        cnl_ref_acc.center = cnl_prod.center
    AND cnl_ref_acc.globalid = cnl_pac.refund_account_globalid
    LEFT JOIN
        invoice_lines_mt il
    ON
        il.center = art.ref_center
    AND il.id = art.ref_id
    AND art.ref_type = 'INVOICE'
    AND il.total_amount != 0
    LEFT JOIN
        products il_prod
    ON
        il_prod.center = il.productcenter
    AND il_prod.id = il.productid
    LEFT JOIN
        product_account_configurations il_pac
    ON
        il_pac.id = il_prod.product_account_config_id
    LEFT JOIN
        accounts il_sale_acc
    ON
        il_sale_acc.center = il_prod.center
    AND il_sale_acc.globalid = il_pac.sales_account_globalid
    LEFT JOIN
        product_group il_pg
    ON
        il_pg.id = il_prod.primary_product_group_id
    WHERE
        REQUEST_TYPE = 5 -- refund
    AND pr.due_date BETWEEN params.from_date AND params.to_date
    )
SELECT
    *
FROM
    crt_api_refunds

UNION ALL

SELECT
    *
FROM
    pr_refunds