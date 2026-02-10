-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                       AS center
          , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                 AS from_date_long
          , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long
          , $$from_date$$::DATE                                            AS from_date
          , $$to_date$$::DATE                                            AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
  , invoice_crt AS
    (
        SELECT DISTINCT
            'invoice_crt' AS transaction_type
          , crt.customercenter
          , crt.customerid
          , crt.paysessionid
          , crt.center AS crt_center
          , crt.id     AS crt_id
          ,
            /* crt.subid                                   AS crt_subid,*/
            longtodatec(crt.transtime,crt.center)::DATE AS "Payment Date"
          , il.center                                   AS il_center
          , il.id                                       AS il_id
          , il.subid                                    AS il_subid
          , il.total_amount                             AS il_total_amount
          , il.total_amount                             AS amount
          , il.net_amount                               AS il_net_amount
          , il.productcenter
          , il.productid
          , il.quantity
          , i.entry_time AS invoice_entry_time
        FROM
            params
        JOIN
            evolutionwellness.cashregistertransactions crt
        ON
            crt.center = params.center
        JOIN
            centers crtc
        ON
            crtc.id = crt.center
        JOIN
            invoices i
        ON
            crt.paysessionid = i.paysessionid
        AND ((
                    crt.customercenter = i.payer_center
                AND crt.customerid = i.payer_id)
            OR  crt.customercenter IS NULL)
        JOIN
            centers crti
        ON
            crti.id = i.center
        AND crti.country = crtc.country
        JOIN
            evolutionwellness.invoice_lines_mt il
        ON
            il.center = i.center
        AND il.id = i.id
        WHERE
            crt.crttype NOT IN (4,10,11,15,16,20)
        AND i.entry_time BETWEEN params.from_date_long AND params.to_date_long
    )
  , sub_lines AS
    (
        SELECT
            paysessionid
          , il_center AS center
          , customercenter
          , customerid
          , 'Sales Line'                                sub_line_type
          , il_center||'inv'||il_id||'ln'|| il_subid    sub_line_id
          , il_total_amount                          AS sub_line_amount
          , il_net_amount                            AS net_amount
          , productcenter
          , productid
          , quantity
          , invoice_entry_time AS entry_time
          , crt_center
        FROM
            invoice_crt
        UNION ALL
        SELECT
            cn.paysessionid
          , cnl.center AS center
          , customercenter
          , customerid
          , 'Refund Line'                              sub_line_type
          , il_center||'cn'||il_id||'ln'|| il_subid    sub_line_id
          , -1*cnl.total_amount                     AS sub_line_amount
          , -1*cnl.net_amount                       AS net_amount
          , cnl.productcenter
          , cnl.productid
          , cnl.quantity
          , invoice_entry_time AS entry_time
          , crt_center
        FROM
            invoice_crt
        JOIN
            evolutionwellness.credit_note_lines_mt cnl
        ON
            cnl.invoiceline_center = invoice_crt.il_center
        AND cnl.invoiceline_id = invoice_crt.il_id
        AND cnl.invoiceline_subid = invoice_crt.il_subid
        JOIN
            evolutionwellness.credit_notes cn
        ON
            cn.center = cnl.center
        AND cn.id = cnl.id
        WHERE
            TO_CHAR(longtodatec(cn.entry_time,cn.center),'yyyy-MM') = TO_CHAR(longtodatec
            (invoice_crt.invoice_entry_time,il_center),'yyyy-MM')
    )
  , res AS
    (
        SELECT
            paysessionid
          , cou.name       AS "Division"
          , a.name         AS "Region"
          , c.name         AS "Club"
          , c.id           AS "Club Number"
          , c.external_id  AS "Club Code"
          , crtc.name      AS "Payment Source"
          , cp.external_id AS "Member Number"
          , CASE
                WHEN customercenter IS NULL
                THEN 'Cash Sales'
                ELSE customercenter||'p'||customerid
            END           AS "Person Key"
          , sub_line_type AS "Line Type"
          , sub_line_id   AS "Line ID"
          , "Sale Date Time"
          , "Revenue Type"
          , "Ledger Group"
          , "Ledger Group Code"
          , "Item"
          , "Item Description"
          , quantity        AS "Qty"
          , sub_line_amount AS "Amount"
          , "Net Amount"
          , "Tax Rate"
          , "Total Tax Amount"
        FROM
            (
                SELECT
                    paysessionid
                  , sl.center
                  , customercenter
                  , customerid
                  , sub_line_type
                  , sub_line_id
                  , longtodatec(entry_time,sl.center) AS "Sale Date Time"
                  , CASE pr.PTYPE
                        WHEN 1
                        THEN 'Goods'
                        WHEN 2
                        THEN 'Service'
                        WHEN 4
                        THEN 'Clipcard'
                        WHEN 5
                        THEN 'Subscription creation'
                        WHEN 6
                        THEN 'Transfer'
                        WHEN 7
                        THEN 'Freeze period'
                        WHEN 8
                        THEN 'Gift card'
                        WHEN 9
                        THEN 'Free gift card'
                        WHEN 10
                        THEN 'Subscription'
                        WHEN 12
                        THEN 'Subscription pro-rata'
                        WHEN 13
                        THEN 'Subscription add-on'
                        WHEN 14
                        THEN 'Access product'
                    END                      AS "Revenue Type"
                  , sac.name                 AS "Ledger Group"
                  , sac.external_id          AS "Ledger Group Code"
                  , pr.center||'prod'||pr.id AS "Item"
                  , pr.name                  AS "Item Description"
                  , quantity
                  , sub_line_amount
                  , net_amount AS "Net Amount"
                  , CASE
                        WHEN net_amount = 0
                        THEN 0
                        ELSE ROUND(((sub_line_amount - COALESCE(net_amount,0)) / net_amount)*100)
                    END                          AS "Tax Rate"
                  , sub_line_amount - net_amount AS "Total Tax Amount"
                  , crt_center
                FROM
                    sub_lines sl
                LEFT JOIN
                    evolutionwellness.products pr
                ON
                    pr.center = sl.productcenter
                AND pr.id = sl.productid
                LEFT JOIN
                    evolutionwellness.product_account_configurations pac
                ON
                    pac.id = pr.product_account_config_id
                LEFT JOIN
                    accounts sac
                ON
                    sac.globalid = pac.sales_account_globalid
                AND sac.center = pr.center ) t
        LEFT JOIN
            persons p
        ON
            p.center = customercenter
        AND p.id = customerid
        LEFT JOIN
            persons cp
        ON
            cp.center = p.transfers_current_prs_center
        AND cp.id = p.transfers_current_prs_id
        LEFT JOIN
            centers c
        ON
            c.id = t.center
        LEFT JOIN
            centers crtc
        ON
            crtc.id = t.crt_center
        JOIN
            evolutionwellness.area_centers ac
        ON
            ac.center = c.id
        JOIN
            evolutionwellness.areas a
        ON
            a.id = ac.area
        AND a.root_area = 99 --reporting scope tree
        JOIN
            evolutionwellness.countries cou
        ON
            cou.id = c.country
        ORDER BY
            paysessionid
    )
  , tst_duplicates AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    *
                  , COUNT(*) over (partition BY "Line ID") AS dupl_line
                FROM
                    res)
        WHERE
            dupl_line > 1
    )
SELECT
    *
FROM
    res