-- This is the version from 2026-02-05
--  
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
    , department_codes AS
    (SELECT
        DISTINCT ppgl.product_center
        ,ppgl.product_id
        ,CASE
            WHEN pr.ptype =12
            THEN 'M''Ship Pro Rata'
            WHEN pr.ptype =10
            THEN 'Membership'
            WHEN pr.ptype =5
            THEN 'Joining Fee'
            WHEN pr.ptype IN(1,2)
            THEN pg.name
        END AS "Department"
        ,CASE
            WHEN pr.ptype =12
            THEN '014'
            WHEN pr.ptype =10
            THEN '047'
            WHEN pr.ptype =5
            THEN '084'
            WHEN pr.ptype IN(1,2)
            THEN pg.external_id
        END AS "DepartmentCode"
    FROM
        products pr
    JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = pr.center
    AND ppgl.product_id = pr.id
    LEFT JOIN
        product_group pg
    ON
        pg.id = ppgl.product_group_id
    AND pg.external_id IS NOT NULL
    AND pg.external_id != ''
    WHERE
        pg.id IS NOT NULL
    OR  pr.ptype IN (5,10,12)
    )
    , crt_lines AS
    ( SELECT
        crt.center AS cash_register_center
        , 01       AS cash_register_id
        ,crt.paysessionid
        ,longtodatec(crt.transtime,crt.center) AS "Date"
        ,CASE crt.CRTTYPE
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
        END AS "Tender"
        , CASE
            WHEN cn.center IS NOT NULL
            THEN -1*crt.amount
            ELSE crt.amount
        END            AS "Tender Amount"
        ,c.external_id AS "ClubID"
        ,COALESCE(CAST(substring(mrp_art.info FROM 1 FOR position('inv' IN mrp_art.info) - 1) AS
                                                                      INTEGER),i.center) AS i_center
        ,COALESCE(CAST(substring(mrp_art.info FROM position('inv' IN mrp_art.info) + 3) AS INTEGER
        ), i.id)                                                   AS i_id
        ,cn.center                                              AS cn_center
        ,cn.id                                                      AS cn_id
        ,COALESCE(pia_art.text,crt.coment)                             AS COMMENT
        ,COALESCE(crt.customercenter, i.payer_center, cn.payer_center) AS customercenter
        , COALESCE(crt.customerid, i.payer_id, cn.payer_id)            AS customerid
        ,cacc.name                                                     AS gl_credit_account_name
        ,dacc.name                                                     AS gl_debit_account_name
        ,cacc.external_id                                              AS
                             gl_credit_account_externalid
        ,dacc.external_id AS gl_debit_account_externalid
        ,cr.name          AS cr_name
        ,cr.type          AS cr_type
    FROM
        params
    JOIN
        cashregistertransactions crt
    ON
        crt.center = params.center
    JOIN
        cashregisters cr
    ON
        cr.center = crt.center
    AND cr.id = crt.id
    JOIN
        centers c
    ON
        c.id = crt.center
    LEFT JOIN
        invoices i
    ON
        crt.paysessionid = i.paysessionid
    AND
        (
            (
                crt.customercenter = i.payer_center
            AND crt.customerid = i.payer_id)
        OR  crt.customercenter IS NULL)
    LEFT JOIN
        credit_notes cn
    ON
        crt.paysessionid = cn.paysessionid
    AND
        (
            (
                crt.customercenter = cn.payer_center
            AND crt.customerid = cn.payer_id)
        OR  crt.customercenter IS NULL)
    LEFT JOIN
        ar_trans pia_art
    ON
        pia_art.center = crt.artranscenter
    AND pia_art.id = crt.artransid
    AND pia_art.subid = crt.artranssubid
    AND
        (
            pia_art.text LIKE 'Payment into account%')
    LEFT JOIN
        ar_trans mrp_art
    ON
        mrp_art.ref_center = crt.gltranscenter
    AND mrp_art.ref_id = crt.gltransid
    AND mrp_art.ref_subid = crt.gltranssubid +1
    AND mrp_art.ref_type = 'ACCOUNT_TRANS'
    AND crt.coment LIKE 'Manual registered payment of invoice%'
    LEFT JOIN
        account_trans act
    ON
        act.center = crt.gltranscenter
    AND act.id = crt.gltransid
    AND act.subid = crt.gltranssubid
    LEFT JOIN
        accounts cacc
    ON
        cacc.center = act.credit_accountcenter
    AND cacc.id = act.credit_accountid
    LEFT JOIN
        accounts dacc
    ON
        dacc.center = act.debit_accountcenter
    AND dacc.id = act.debit_accountid
    WHERE
        crt.transtime BETWEEN params.from_date_long AND params.to_date_long
    AND crt.amount != 0
    )
    , det AS
    ( SELECT
        t.paysessionid
        ,"ClubID" as "Transaction Club ID"
        ,c.id as "Member Club ID"
        ,c.name as "Member Club Name" 
        , "Date"
        ,cr_type  AS "Cash Register Type" 
        , cr_name AS "Cash Register Name"
        ,pr.name  AS "Product Name"
        , dc."DepartmentCode"
        ,dc."Department"
        , t.customercenter||'p'||t.customerid                                         AS "PersonKey"
        , gl_credit_account_name                                            AS "Credit Account Name"
        ,gl_credit_account_externalid                                AS "Credit Account External ID"
        , gl_debit_account_name                                              AS "Debit Account Name"
        ,gl_debit_account_externalid                                  AS "Debit Account External ID"
        , COALESCE(il.total_amount ,-1*cl.total_amount )                                 AS "Amount"
        , COALESCE(il.total_amount - il.net_amount ,-1*(cl.total_amount - cl.net_amount )) AS
        "Tax Amount"
        ,"Tender"
        ,"Tender Amount"
        ,t.comment
    FROM
        crt_lines t
    LEFT JOIN
        invoice_lines_mt il
    ON
        il.center = i_center
    AND il.id = i_id
    LEFT JOIN
        credit_note_lines_mt cl
    ON
        cl.center = cn_center
    AND cl.id = cn_id
    LEFT JOIN
        products pr
    ON
        (
            pr.center = il.productcenter
        AND pr.id = il.productid)
    OR
        (
            pr.center = cl.productcenter
        AND pr.id = cl.productid)
    LEFT JOIN
        department_codes dc
    ON
        dc.product_center = pr.center
    AND dc.product_id = pr.id
    left join centers c on c.id = t.customercenter
    )
SELECT
    *
FROM
    det