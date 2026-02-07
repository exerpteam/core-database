WITH
    RECURSIVE params AS MATERIALIZED
    ( SELECT
        c.id                                         AS center
        , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                 AS from_date_long
        , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long
        , $$from_date$$::DATE                                            AS from_date
        , $$to_date$$::DATE                                            AS to_date
    FROM
        evolutionwellness.centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , centers_in_area AS
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
    , lines AS
    ( SELECT
        art.center||'ar'||art.id||'art'||art.subid AS "AR Transaction ID"
        , cou.name                                 AS "Country"
        , a.name                                   AS "Region"
        , c.name                                   AS "Club"
        , c.id                                     AS "Club Number"
        , c.external_id                            AS "Club Code"
        , cp.external_id                           AS "Member Number"
        , p.center||'p'||p.id                      AS "Person Key"
        , cp.center||'p'||cp.id                    AS "Current Person Key"
        , CASE
            WHEN staff.external_id IN ('601'
                                       , '2410' 
                                       , '10409')
            THEN 'Online'
            ELSE sc.name
        END                                        AS "Payment Source"
        , staff.fullname                           AS "Operator"
        , longtodateC(art.entry_time, sc.id)::TEXT AS "Head Office Time"
        , CASE
            WHEN staff.external_id IN ('601'
                                       , '2410' 
                                       , '10409')
            THEN 'Online'
            WHEN art.ref_type = 'CREDIT_NOTE'
            THEN 'Refund to Account'
            WHEN art.ref_type = 'ACCOUNT_TRANS'
            THEN 'Manual Adjustment'
        END                                     AS "Type"
        , pr.center||'prod'||pr.id              AS "Item"
        , pr.name                               AS "Item Description"
        , rac.name                              AS "Ledger Group"
        , rac.external_id                       AS "Ledger Group Code"
        , cnl.quantity                          AS "Qty"
        , COALESCE(cnl.total_amount,art.amount) AS "Total Sale Amount"
        , cnl.total_amount - cnl.net_amount     AS "Total Tax Amount"
        ,
        -- not sure what to put in the Adjustment type here
        CASE
            WHEN staff.external_id IN ('601'
                                       , '2410' 
                                       , '10409')
            AND cct.id IS NOT NULL
            THEN 'CREDIT_CARD'
            WHEN crt.id IS NOT NULL
            THEN COALESCE(cpm.name, CASE crt.CRTTYPE
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
                END )
            ELSE 'Manual Adjustment'
        END        AS "Tender Type"
        , art.text AS "Notes"
    FROM
        evolutionwellness.ar_trans art
    JOIN
        evolutionwellness.centers c
    ON
        c.id = art.center
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
    JOIN
        params
    ON
        params.center = c.id
    JOIN
        evolutionwellness.account_receivables ar
    ON
        ar.center = art.center
    AND ar.id= art.id
    JOIN
        evolutionwellness.persons p
    ON
        p.center = ar.customercenter
    AND p.id = ar.customerid
    JOIN
        evolutionwellness.persons cp
    ON
        p.transfers_current_prs_center = cp.center
    AND p.transfers_current_prs_id = cp.id
    JOIN
        evolutionwellness.employees emp
    ON
        emp.center = art.employeecenter
    AND emp.id = art.employeeid
    JOIN
        persons staff
    ON
        staff.center = emp.personcenter
    AND staff.id = emp.personid
    JOIN
        centers sc
    ON
        sc.id = emp.center
    LEFT JOIN
        evolutionwellness.credit_notes cn
    ON
        cn.center = art.ref_center
    AND cn.id = art.ref_id
    AND ref_type = 'CREDIT_NOTE'
    LEFT JOIN
        evolutionwellness.credit_note_lines_mt cnl
    ON
        cnl.center = cn.center
    AND cnl.id = cn.id
    LEFT JOIN
        evolutionwellness.products pr
    ON
        pr.center = cnl.productcenter
    AND pr.id = cnl.productid
    LEFT JOIN
        evolutionwellness.product_account_configurations pac
    ON
        pac.id = pr.product_account_config_id
    LEFT JOIN
        accounts rac
    ON
        rac.globalid = pac.refund_account_globalid
    AND rac.center = pr.center
    LEFT JOIN
        evolutionwellness.creditcardtransactions cct
    ON
        cct.transaction_id = art.info
    LEFT JOIN
        evolutionwellness.cashregistertransactions crt
    ON
        art.center = crt.artranscenter
    AND art.id = crt.artransid
    AND art.subid = crt.artranssubid
    AND
        (
            art.text LIKE 'Payment into account%'
        OR  art.text LIKE 'การชำระเงินเข้าบัญชี%'
        OR  art.text LIKE 'Pembayaran ke rekening%')
    LEFT JOIN
        center_config_payment_method_id cpm
    ON
        cpm.center_id = crt.center
    AND crt.config_payment_method_id = cpm.id
    LEFT JOIN -- exclude DD transactions
        account_trans atr
    ON
        atr.center = art.ref_center
    AND atr.id = art.ref_id
    AND atr.subid = art.ref_subid
    AND art.ref_type = 'ACCOUNT_TRANS'
    AND atr.info_type = 3
    AND art.text NOT LIKE 'Automatic placement: Adyen%'
    WHERE
        art.entry_time BETWEEN params.from_date_long AND params.to_date_long
    AND art.amount > 0
    AND emp.center IN(100,200,300,400,500,999)
    AND atr.id IS NULL
    AND NOT
        (
            emp.center = 100
        AND emp.id = 1)
    AND
        (
            crt.id IS NOT NULL
        OR  NOT
            (
                art.text LIKE 'Payment into account%'
            OR  art.text LIKE 'การชำระเงินเข้าบัญชี%'
            OR  art.text LIKE 'Pembayaran ke rekening%'))
    )
    , res AS
    ( SELECT
        '   Sale Line' AS "Line Type"
        , "Country"
        , "Region"
        , "Club"
        , "Club Number"
        , "Club Code"
        , "AR Transaction ID"
        , "Member Number"
        , "Person Key"
        , "Payment Source"
        , "Operator"
        , "Head Office Time"
        , "Type"
        , "Item"
        , "Item Description"
        , "Ledger Group"
        , "Ledger Group Code"
        , "Qty"
        , "Total Sale Amount"
        , "Total Tax Amount"
        , "Tender Type"
        , "Notes"
    FROM
        lines
    )
SELECT
    *
FROM
    res