-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    RECURSIVE centers_in_area AS
    (
        SELECT
            a.id,
            a.parent,
            ARRAY[id] AS chain_of_command_ids,
            2         AS level
        FROM
            areas a
        WHERE
            a.types LIKE '%system%'
        AND a.parent IS NULL
        UNION ALL
        SELECT
            a.id,
            a.parent,
            array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
            cin.level + 1                                AS level
        FROM
            areas a
        JOIN
            centers_in_area cin
        ON
            cin.id = a.parent
    )
    ,
    areas_total AS
    (
        SELECT
            cin.id AS ID,
            cin.level,
            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
            centers_in_area cin
        LEFT JOIN
            centers_in_area AS b -- join provides subordinates
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            1,2
    )
    ,
    scope_center AS
    (
        SELECT
            'A'               AS SCOPE_TYPE,
            areas_total.ID    AS SCOPE_ID,
            c.ID              AS CENTER_ID,
            areas_total.level AS LEVEL
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
    ,
    center_config_payment_method_id AS
    (
        SELECT
            center_id,
            (xpath('//attribute/@id',xml_element))[1]::text::INTEGER     AS id,
            (xpath('//attribute/@name',xml_element))[1]::text            AS name,
            (xpath('//attribute/@globalAccountId',xml_element))[1]::text AS globalAccountId
        FROM
            (
                SELECT
                    center_id,
                    unnest(xpath('//attribute',xmlparse(document convert_from(mimevalue, 'UTF-8'))
                    )) AS xml_element
                FROM
                    (
                        SELECT
                            a.name,
                            sc.center_id,
                            sys.mimevalue,
                            sc.level,
                            MAX(sc.LEVEL) over (partition BY sc.CENTER_ID) AS maxlevel
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
    ,
    params AS
    (
        SELECT
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:CutDate AS DATE) + INTERVAL '1 day'),
            'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS cutDate
        FROM
            centers c
    )
    
SELECT
    t."Txn ID",
    t."Club",
    t."Club Number",
    t."Club Code",
    t."Member Number",
    t."Person ID",
    t."Join Date",
    t."Plan Start Date",
    t."Membership Status",
    t."Payment Status",
    t."Plan Name",
    t."Balance Date",
    t."Current Account Balance",
    t."Payment Date",
    t."Payment Type",
    t."Days Since Paid",
    t."Operator",
    t."Original Paid Amount",
    t."Allocated Amount" - COALESCE(SUM(artm.amount),0) AS "Allocated Amount",
    t."Remaining Unallocated Amount" + COALESCE(SUM(artm.amount),0) AS "Remaining Unallocated Amount",
    t."Next Billed Amount",
    t."Next Billed Date"  
FROM
(
SELECT
    CASE
        WHEN art.ref_type = 'ACCOUNT_TRANS'
        THEN art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid
        ELSE art.ref_center||'cred'||art.ref_id
    END                                   AS "Txn ID",
    c.name                                AS "Club",
    c.id                                  AS "Club Number",
    c.external_id                         AS "Club Code",
    p.external_id                         AS "Member Number",
    p.center||'p'||p.id                   AS "Person ID",
    longtodatec(s.creation_time,s.center) AS "Join Date",
    s.start_date                          AS "Plan Start Date",
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE NULL
    END AS "Membership Status",
    CASE s.SUB_STATE
        WHEN 1
        THEN 'NONE'
        WHEN 2
        THEN 'AWAITING_ACTIVATION'
        WHEN 3
        THEN 'UPGRADED'
        WHEN 4
        THEN 'DOWNGRADED'
        WHEN 5
        THEN 'EXTENDED'
        WHEN 6
        THEN 'TRANSFERRED'
        WHEN 7
        THEN 'REGRETTED'
        WHEN 8
        THEN 'CANCELLED'
        WHEN 9
        THEN 'BLOCKED'
        WHEN 10
        THEN 'CHANGED'
        ELSE NULL
    END                                    AS "Payment Status",
    prod.name                              AS "Plan Name",
    params.cutDate                         AS "Balance Date",
    ar.balance                             AS "Current Account Balance",
    longtodatec(art.entry_time,art.center) AS "Payment Date",
    STRING_AGG(DISTINCT
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
    END, ', ')                                                  AS "Payment Type",
    CURRENT_DATE - longtodatec(art.entry_time,art.center)::DATE AS "Days Since Paid",
    empp.fullname                                               AS "Operator",
    art.amount                                                  AS "Original Paid Amount",
    art.amount - art.unsettled_amount                           AS "Allocated Amount",
    art.unsettled_amount                                        AS "Remaining Unallocated Amount",
    s.subscription_price                                        AS "Next Billed Amount",
    CASE
        WHEN st.st_type = 0
        THEN NULL
        ELSE s.billed_until_date + 1
    END AS "Next Billed Date",
    art.center,
    art.id,
    art.subid
FROM
    evolutionwellness.persons p
JOIN
    evolutionwellness.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    evolutionwellness.ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
JOIN
    evolutionwellness.centers c
ON
    p.center = c.id
LEFT JOIN
    evolutionwellness.subscriptions s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.state IN (2,4)
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
    evolutionwellness.employees emp
ON
    emp.center = art.employeecenter
AND emp.id = art.employeeid
LEFT JOIN
    evolutionwellness.persons empp
ON
    empp.center = emp.personcenter
AND empp.id = emp.personid
LEFT JOIN
    evolutionwellness.ar_trans cart
ON
    cart.ref_center = art.ref_center
AND cart.ref_id = art.ref_id
AND cart.ref_subid = art.ref_subid
AND art.ref_type = 'ACCOUNT_TRANS'
AND cart.ref_type = 'ACCOUNT_TRANS'
AND cart.id != art.id
LEFT JOIN
    evolutionwellness.art_match arm
ON
    arm.art_paid_center = cart.center
AND arm.art_paid_id= cart.id
AND arm.art_paid_subid = cart.subid
AND arm.cancelled_time IS NULL
LEFT JOIN
    evolutionwellness.cashregistertransactions crtat
ON
    crtat.artranscenter = arm.art_paying_center
AND crtat.artransid = arm.art_paying_id
AND crtat.artranssubid= arm.art_paying_subid
LEFT JOIN
    center_config_payment_method_id ccpm
ON
    ccpm.center_id = crtat.artranscenter
AND ccpm.id = crtat.config_payment_method_id
LEFT JOIN
    evolutionwellness.credit_notes cn
ON
    cn.center = art.ref_center
AND cn.id = art.ref_id
AND art.ref_type = 'CREDIT_NOTE'
JOIN
    params
ON
    params.center_id = art.center
WHERE
    art.status != 'CLOSED'
AND art.amount > 0
AND p.center IN (:Scope)
AND p.sex != 'C'
AND art.entry_time < params.cutDate 
GROUP BY
    art.ref_type,
    art.ref_center,
    art.ref_id,
    art.ref_subid,
    c.name ,
    c.id ,
    c.external_id ,
    p.external_id ,
    p.center,
    p.id ,
    longtodatec(s.creation_time,s.center),
    s.start_date ,
    s.STATE,
    s.SUB_STATE,
    prod.name ,
    ar.balance ,
    art.entry_time,
    art.center,
    empp.fullname ,
    art.amount ,
    art.amount - art.unsettled_amount,
    art.unsettled_amount ,
    s.subscription_price,
    st.st_type ,
    s.billed_until_date,
    art.center,
    art.id,
    art.subid,
    params.cutDate
    )t
JOIN
    params
ON
    params.center_id = t.center    
LEFT JOIN
    evolutionwellness.art_match artm
ON
    artm.art_paying_center = t.center
AND artm.art_paying_id= t.id
AND artm.art_paying_subid = t.subid
AND artm.cancelled_time IS NULL
AND artm.entry_time > params.cutDate
LEFT JOIN
    evolutionwellness.ar_trans artt
ON
    artm.art_paid_center = artt.center
AND artm.art_paid_id = artt.id
AND artm.art_paid_subid = artt.subid
AND artt.trans_time > params.cutDate 
GROUP BY
    t."Txn ID",
    t."Club",
    t."Club Number",
    t."Club Code",
    t."Member Number",
    t."Person ID",
    t."Join Date",
    t."Plan Start Date",
    t."Membership Status",
    t."Payment Status",
    t."Plan Name",
    t."Balance Date",
    t."Current Account Balance",
    t."Payment Date",
    t."Payment Type",
    t."Days Since Paid",
    t."Operator",
    t."Original Paid Amount",
    t."Allocated Amount", 
    t."Remaining Unallocated Amount", 
    t."Next Billed Amount",
    t."Next Billed Date"     