-- This is the version from 2026-02-05
--  
WITH
    RECURSIVE params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                             AS center
        , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                 AS from_date_long
        , datetolongc($$to_date$$::  DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long
        , $$from_date$$::DATE                                            AS from_date
        , $$to_date$$::  DATE                                            AS to_date
    FROM
        centers c
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
    
    UNION ALL
    
    SELECT
        DISTINCT 'T' AS SCOPE_TYPE
        , a.id       AS SCOPE_ID
        , c.ID       AS CENTER_ID
        , 1          AS LEVEL
    FROM
        areas a
    CROSS JOIN
        centers c
    WHERE
        a.parent IS NULL
    
    UNION ALL
    
    SELECT
        'G'    AS SCOPE_TYPE
        , 1    AS SCOPE_ID
        , c.ID AS CENTER_ID
        , 0    AS LEVEL
    FROM
        centers c
    
    UNION ALL
    
    SELECT
        'C'    AS SCOPE_TYPE
        , c.id AS SCOPE_ID
        , c.ID AS CENTER_ID
        , 999  AS LEVEL
    FROM
        centers c
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
                systemproperties SYS
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
SELECT
    p.center||'p'||p.id AS "Member ID"
    , p.external_id     AS "Legacy ID"
    ,art.amount         AS "Legacy Debt Amount"
    ,arm.amount         AS "Debt Paid Amount"
    ,art.amount + arm.amount "Post Payment Debt Amount"
    ,art.unsettled_amount AS "Overdue Debt"
    ,CASE
        WHEN art_paying.ref_type = 'CREDIT_NOTE'
        THEN 'Credit Note'
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
           when art_paying.ref_type = 'ACCOUNT_TRANS' then 'Account Transaction'
    END AS "Payment method"
    ,art_paying.text,acc.name as "Debit account", cacc.name as "Credit Account"
FROM
    persons p
JOIN
    params
ON
    params.center = p.center
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
AND art.amount < 0
JOIN
    art_match arm
ON
    arm.art_paid_center = art.center
AND arm.art_paid_id = art.id
AND arm.art_paid_subid = art.subid
JOIN
    ar_trans art_paying
ON
    art_paying.center = arm.art_paying_center
AND art_paying.id = arm.art_paying_id
AND art_paying.subid = arm.art_paying_subid
LEFT JOIN
    cashregistertransactions crt
ON
    art_paying.center = crt.artranscenter
AND art_paying.id = crt.artransid
AND art_paying.subid = crt.artranssubid
LEFT JOIN
    center_config_payment_method_id cpm
ON
    cpm.center_id = crt.center
AND crt.config_payment_method_id = cpm.id
left join account_trans act on act.center = art_paying.ref_center and act.id = art_paying.ref_id and act.subid = art_paying.ref_subid and art_paying.ref_type = 'ACCOUNT_TRANS' 
left join accounts acc on acc.center = act.debit_accountcenter AND acc.id = act.debit_accountid
left join accounts cacc on cacc.center = act.credit_accountcenter AND cacc.id = act.credit_accountid
WHERE
    art_paying.entry_time BETWEEN params.from_date_long AND params.to_date_long