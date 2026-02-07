-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                                               AS center
        , datetolongc(($$for_Date$$)::DATE::VARCHAR,c.id) AS from_date_long
        , datetolongc((($$for_Date$$)::date +interval '1 day')::                 DATE::VARCHAR,c.id) AS to_date_long
    FROM
        centers c
        where c.id = :center
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
            WHEN pr.ptype IN(1,2,4)
            THEN pg.name
        END AS "Department"
        ,CASE
            WHEN pr.ptype =12
            THEN '014'
            WHEN pr.ptype =10
            THEN '047'
            WHEN pr.ptype =5
            THEN '084'
            WHEN pr.ptype IN(1,2,4)
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
    AND cr.type = 'POS'
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
    WHERE
        crt.transtime BETWEEN params.from_date_long AND params.to_date_long
    AND crt.center != 100
    AND crt.config_payment_method_id IS NULL
    and crt.crttype not in (16, 20)
        -- AND crt.amount != 0
    )
    , c_file_det AS
    ( SELECT
        t.paysessionid
        , "ClubID"
        , "Date"
        , '01' AS "TillID"
        , CASE
            WHEN "Tender" IN('CASH'
                             ,'CASH ADJUSTMENT'
                             ,'CASH TRANSFER'
                             ,'TRANSFER BACK CASH COINS'
                             ,'CHANGE'
                             ,'PAYOUT CASH')
            THEN 30
            WHEN "Tender" IN ('VOUCHER'
                              , 'PAYOUT CREDIT CARD'
                              ,'CONFIG PAYMENT METHOD'
                              ,'PAYMENT AR'
                              ,'GIFT CARD'
                              ,'DEBIT OR CREDIT CARD'
                              ,'CREDIT CARD'
                              ,'DEBIT CARD'
                              ,'PAID BY CASH AR ACCOUNT'
                              , 'CREDIT CARD ADJUSTMENT')
            THEN 33
        END AS "FunctionType"
        ,CASE
            WHEN "Tender" IN('CASH'
                             ,'CASH ADJUSTMENT'
                             ,'CASH TRANSFER'
                             ,'TRANSFER BACK CASH COINS'
                             ,'CHANGE'
                             ,'PAYOUT CASH')
            THEN '001'
            WHEN "Tender" IN ( 'PAYOUT CREDIT CARD'
                              ,'DEBIT OR CREDIT CARD'
                              ,'CREDIT CARD'
                              ,'DEBIT CARD'
                              ,'CREDIT CARD ADJUSTMENT')
            THEN '001'
            WHEN "Tender" IN ('VOUCHER')
            THEN '003'
            WHEN "Tender" IN ( 'PAYMENT AR'
                              ,'PAID BY CASH AR ACCOUNT')
            THEN '004'
            WHEN "Tender" IN ( 'CONFIG PAYMENT METHOD')
            THEN '018'
        END                                   AS "FunctionNumber"
        ,"Tender Amount"                      AS "Amount"
        , t.customercenter||'p'||t.customerid AS "PersonKey"
        ,"Tender"
    FROM
        (SELECT
            *
            , ROW_NUMBER() over (
                             PARTITION BY
                                 paysessionid
                                 , "Tender") AS rnk
        FROM
            crt_lines) t
    WHERE
        rnk = 1
    )
    , c_file AS
    (SELECT
        "ClubID"
        , TO_CHAR("Date"::DATE,'dd/mm/yyyy') AS "Date"
        ,"TillID"
        ,"FunctionType"
        ,"FunctionNumber"
        ,SUM("Amount") AS "Amount"
        ,'0.00'        AS "Filler"
    FROM
        c_file_det where "Tender" not IN ( 'PAYMENT AR'
                              ,'PAID BY CASH AR ACCOUNT')
    GROUP BY
        "ClubID"
        ,"Date"::DATE
        ,"TillID"
        ,"FunctionType"
        ,"FunctionNumber"
    )
    , d_file_det AS
    ( SELECT
        t.paysessionid
        ,"ClubID"
        , "Date"
        ,pr.name AS "Product Name"
        , dc."DepartmentCode"
        ,dc."Department"
        , t.customercenter||'p'||t.customerid            AS "PersonKey"
        , COALESCE(il.total_amount ,-1*cl.total_amount ) AS "Amount"
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
    )
    , d_file AS
    ( SELECT
        "ClubID"
        , TO_CHAR("Date"::DATE,'dd/mm/yyyy') AS "Date"
        ,"DepartmentCode"
        , SUM("Amount") AS "Amount"
        ,'01'         AS "Filler"
    FROM
        d_file_det where "Tender" not IN ( 'PAYMENT AR'
                              ,'PAID BY CASH AR ACCOUNT')
    GROUP BY
        "ClubID"
        , "Date"::DATE
        ,"DepartmentCode"
    )
SELECT
    *
FROM
    c_file