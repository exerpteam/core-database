WITH
    RECURSIVE centers_in_area AS
    ( SELECT
        a.id 
        , a.parent 
        , ARRAY[id] AS chain_of_command_ids 
        , 2         AS level
    FROM
        areas a
    WHERE
        a.types LIKE '%system%'
    AND a.parent IS NULL
     
    UNION ALL
     
    SELECT
        a.id 
        , a.parent 
        , array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids 
        , cin.level + 1                                AS level
    FROM
        areas a
    JOIN
        centers_in_area cin
    ON
        cin.id = a.parent
    )
    , areas_total AS
    ( SELECT
        cin.id AS ID 
        , cin.level 
        , unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
    FROM
        centers_in_area cin
    LEFT JOIN
        centers_in_area AS b -- join provides subordinates
    ON
        cin.id = ANY (b.chain_of_command_ids)
    AND cin.level <= b.level
    GROUP BY
        1 
        ,2
    )
    , scope_center AS
    ( SELECT
        'A'                 AS SCOPE_TYPE 
        , areas_total.ID    AS SCOPE_ID 
        , c.ID              AS CENTER_ID 
        , areas_total.level AS LEVEL
    FROM
        areas_total
    LEFT JOIN
        area_centers ac
    ON
        ac.area = areas_total.sub_areas
    JOIN
        centers c
    ON
        ac.CENTER = c.id
    )
    , center_config_payment_method_id AS
    ( SELECT
        center_id 
        , (xpath('//attribute/@id',xml_element))[1]::             TEXT::INTEGER AS id 
        , (xpath('//attribute/@name',xml_element))[1]::           TEXT          AS NAME 
        , (xpath('//attribute/@globalAccountId',xml_element))[1]::TEXT          AS globalAccountId
    FROM
        ( SELECT
            center_id 
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(mimevalue, 'UTF-8')) )) AS 
            xml_element
        FROM
            ( SELECT
                a.name 
                , sc.center_id 
                , sys.mimevalue 
                , sc.level 
                , MAX(sc.LEVEL) over ( 
                                  PARTITION BY 
                                      sc.CENTER_ID) AS maxlevel
            FROM
                evolutionwellness.systemproperties SYS
            JOIN
                scope_center sc
            ON
                sc.SCOPE_ID = sys.scope_id
            AND sys.scope_type = sc.SCOPE_TYPE
            JOIN
                areas a
            ON
                a.id = sys.scope_id
            WHERE
                sys.globalid = 'PaymentMethodsConfig') t
        WHERE
            maxlevel = LEVEL)
    ) 
    , params AS
    ( SELECT
        /*+ materialize */
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate
        , c.id                                                               AS CENTER_ID
        , CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI')
        ,c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
    )
    , trans AS
    ( SELECT
        STRING_AGG(artp.amount::TEXT,',') AS original_overpayment
        ,STRING_AGG(DISTINCT
        CASE
            WHEN crtat.config_payment_method_id IS NOT NULL
            THEN ccpm.name
            ELSE
                CASE crtat.CRTTYPE
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
                    ELSE 'CREDIT NOTE'
                END
        END, ', ')                   AS "Overpayment Tender Types"
        , SUM(artm.amount)           AS total_allocated_amount
        , SUM(artp.unsettled_amount) AS total_unsettled_amount
        , STRING_AGG(DISTINCT TO_CHAR(longtodatec(artp.entry_time,artp.center),'yyyy-MM-dd'),',')
        AS payment_dates
        , art.center
        , art.id
        , art.subid
        , art.ref_type
        , art.ref_center
        , art.ref_id
        , art.ref_subid
        , art.text
        , art.trans_time
    FROM
        params
    JOIN
        evolutionwellness.ar_trans art
    ON
        art.center = params.CENTER_ID
    JOIN
        evolutionwellness.art_match artm
    ON
        artm.art_paid_center = art.center
    AND artm.art_paid_id = art.id
    AND artm.art_paid_subid = art.subid
    AND artm.cancelled_time IS NULL
    JOIN
        evolutionwellness.ar_trans artp
    ON
        artp.center = artm.art_paying_center
    AND artp.id = artm.art_paying_id
    AND artp.subid = artm.art_paying_subid
    LEFT JOIN
        evolutionwellness.invoices inv
    ON
        art.ref_center = inv.center
    AND art.ref_id = inv.id
    AND art.ref_type = 'INVOICE'
    LEFT JOIN
        evolutionwellness.cashregistertransactions crtat
    ON
        crtat.artranscenter = artp.center
    AND crtat.artransid = artp.id
    AND crtat.artranssubid= artp.subid
    LEFT JOIN
        center_config_payment_method_id ccpm
    ON
        ccpm.center_id = crtat.artranscenter
    AND ccpm.id = crtat.config_payment_method_id
    WHERE
        art.entry_time BETWEEN params.FromDate AND params.ToDate
    AND art.trans_time > artp.trans_time
    AND art.center IN (:Scope)
        /*
        inv.center = 109
        AND inv.id = 4201*/
    GROUP BY
        art.center
        , art.id
        , art.subid
        , art.ref_type
        , art.ref_center
        , art.ref_id
        , art.ref_subid
    )
    , res AS
    ( SELECT
        sub."Line ID"
        , sub."Club"
        , sub."Club Number"
        , sub."Club Code"
        , sub."Member Number"
        , sub."Person ID"
        , sub."Plan Start Date"
        , sub."Plan Name"
        , sub."Payment Dates"
        , sub."Original Overpayments"
        , sub."Overpayment Tender Types"
        , sub."Sale Line ID"
        , sub."Line Sales Price"
        , ROUND(sub."Line Sales Price"*sub.tax_rate,2) AS "Tax Amount"
        , (ROUND(sub.tax_rate,2)*100)::INTEGER ||'%'   AS "Tax Rate"
        , sub."Allocated Amount"
        , sub."Allocated Item"
        , sub."Ledger Group"
        , sub."Ledger Group Code"
        , sub."Allocation Date"
    FROM
        (SELECT
            CASE
                WHEN trans.ref_type = 'INVOICE'
                THEN trans.ref_center||'inv'||trans.ref_id
                WHEN trans.ref_type = 'ACCOUNT_TRANS'
                THEN trans.ref_center||'acc'||trans.ref_id||'tr'||trans.ref_subid
            END                   AS "Line ID"
            , c.name              AS "Club"
            , c.id                AS "Club Number"
            , c.external_id       AS "Club Code"
            , cp.external_id      AS "Member Number"
            , p.center||'p'||p.id AS "Person ID"
            , s.start_date        AS "Plan Start Date"
            , prod.name           AS "Plan Name"
            , trans.payment_dates AS "Payment Dates"
            , CASE
                WHEN ROW_NUMBER() over (
                                    PARTITION BY
                                        trans.center
                                        ,trans.id
                                        , trans.subid
                                    ORDER BY
                                        trans.subid ASC ) = 1
                THEN trans.original_overpayment
                ELSE NULL
            END AS "Original Overpayments"
            , CASE
                WHEN ROW_NUMBER() over (
                                    PARTITION BY
                                        trans.center
                                        ,trans.id
                                        , trans.subid
                                    ORDER BY
                                        trans.subid ASC ) = 1
                THEN "Overpayment Tender Types"
                ELSE NULL
            END
            as "Overpayment Tender Types" 
            , invl.center||'inv'||invl.id||'ln'||invl.subid            AS "Sale Line ID"
            , COALESCE(invl.total_amount,trans.total_allocated_amount) AS "Line Sales Price"
            ,CASE
                WHEN invl.net_amount = 0
                OR  invl.net_amount IS NULL
                THEN 0
                ELSE ROUND((invl.total_amount - invl.net_amount) / invl.net_amount,2)
            END AS tax_rate
            , CASE
                WHEN trans.ref_type = 'ACCOUNT_TRANS'
                THEN trans.total_allocated_amount
                WHEN trans.total_allocated_amount - SUM ( invl.total_amount ) over
                                                                                    (
                                                                                PARTITION BY
                                                                                    trans.center
                                                                                    , trans.id
                                                                                    , trans.subid
                                                                                ORDER BY
                                                                                    (pr.ptype = 10
                                                                                    )::INTEGER
                                                                                    DESC ) +
                    invl.total_amount < 0
                THEN 0
                WHEN trans.total_allocated_amount < SUM ( invl.total_amount ) over
                                                                                    (
                                                                                PARTITION BY
                                                                                    trans.center
                                                                                    , trans.id
                                                                                    , trans.subid
                                                                                ORDER BY
                                                                                    (pr.ptype = 10
                                                                                    )::INTEGER
                                                                                    DESC )
                THEN trans.total_allocated_amount
                ELSE invl.total_amount
            END                                              AS "Allocated Amount"
            , COALESCE ( pr.name, trans.text )               AS "Allocated Item"
            , sac.name                                       AS "Ledger Group"
            , sac.external_id                                AS "Ledger Group Code"
            , longtodatec ( trans.trans_time, trans.center ) AS "Allocation Date"
        FROM
            trans
        JOIN
            evolutionwellness.centers c
        ON
            c.id = trans.center
        JOIN
            params
        ON
            params.center_id = c.id
        JOIN
            evolutionwellness.account_receivables ar
        ON
            trans.center = ar.center
        AND trans.id = ar.id
        AND ar.ar_type = 4
        JOIN
            evolutionwellness.persons p
        ON
            ar.customercenter = p.center
        AND ar.customerid = p.id
        JOIN
            evolutionwellness.persons cp
        ON
            p.transfers_current_prs_center = cp.center
        AND p.transfers_current_prs_id = cp.id
        LEFT JOIN
            evolutionwellness.subscriptions s
        ON
            p.center = s.owner_center
        AND p.id = s.owner_id
        AND s.state IN ( 2
                        , 4 )
        LEFT JOIN
            evolutionwellness.subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        LEFT JOIN
            evolutionwellness.products prod
        ON
            prod.center = st.center
        AND prod.id = st.id
        LEFT JOIN
            evolutionwellness.account_trans act
        ON
            trans.ref_center = act.center
        AND trans.ref_id = act.id
        AND trans.ref_subid = act.subid
        AND trans.ref_type = 'ACCOUNT_TRANS'
        LEFT JOIN
            evolutionwellness.invoices inv
        ON
            trans.ref_center = inv.center
        AND trans.ref_id = inv.id
        AND trans.ref_type = 'INVOICE'
        LEFT JOIN
            evolutionwellness.invoice_lines_mt invl
        ON
            inv.center = invl.center
        AND inv.id = invl.id
        LEFT JOIN
            products pr
        ON
            pr.center = invl.productcenter
        AND pr.id = invl.productid
        LEFT JOIN
            evolutionwellness.product_account_configurations pac
        ON
            pac.id = pr.product_account_config_id
        LEFT JOIN
            accounts sac
        ON
            sac.globalid = pac.sales_account_globalid
        AND sac.center = pr.center
            /* WHERE
            p.center = 117
            AND p.id = 1891*/
        ) sub
    )
    , tst_reconcile AS
    ( -- compare to Billing batch report tst, should be equal
    SELECT
        COUNT(*)
        , SUM("Allocated Amount") "Allocated Amount"
        /*,
        SUM("Remaining Unallocated Amount") "Remaining Unallocated Amount"*/
    FROM
        res
    )
SELECT
    *
FROM
    res