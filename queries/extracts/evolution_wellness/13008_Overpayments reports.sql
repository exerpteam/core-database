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
    ),
        params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate                        
      FROM
          centers c
  )
SELECT DISTINCT
    CASE
        WHEN art.ref_type = 'ACCOUNT_TRANS'
        THEN art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid
        ELSE art.ref_center||'cred'||art.ref_id
    END                                   AS "Txn ID",
    emppc.name                            AS "Club",
    emppc.id                              AS "Club Number",
    emppc.external_id                     AS "Club Code",
    p.external_id                         AS "Member Number",
    p.center||'p'||p.id                   AS "Person ID",
    longtodatec(s.creation_time,s.center) AS "Join Date",
    longtodatec(art.entry_time,art.center) AS "Payment Date",
    CAST((longtodatec(art.entry_time,art.center)) AS time) AS "Payment time",
    CASE
        WHEN crtat.config_payment_method_id IS NOT NULL THEN ccpm.name
        WHEN crtat.CRTTYPE IS NOT NULL THEN
            CASE crtat.CRTTYPE
                WHEN 1 THEN 'CASH'
                WHEN 2 THEN 'CHANGE'
                WHEN 3 THEN 'RETURN ON CREDIT'
                WHEN 4 THEN 'PAYOUT CASH'
                WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
                WHEN 6 THEN 'DEBIT CARD'
                WHEN 7 THEN 'CREDIT CARD'
                WHEN 8 THEN 'DEBIT OR CREDIT CARD'
                WHEN 9 THEN 'GIFT CARD'
                WHEN 10 THEN 'CASH ADJUSTMENT'
                WHEN 11 THEN 'CASH TRANSFER'
                WHEN 12 THEN 'PAYMENT AR'
                WHEN 13 THEN 'CONFIG PAYMENT METHOD'
                WHEN 14 THEN 'CASH REGISTER PAYOUT'
                WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
                WHEN 16 THEN 'CLOSING CASH ADJUST'
                WHEN 17 THEN 'VOUCHER'
                WHEN 18 THEN 'PAYOUT CREDIT CARD'
                WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
                WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
                WHEN 21 THEN 'TRANSFER BACK CASH COINS'
                WHEN 22 THEN 'INSTALLMENT PLAN'
                WHEN 100 THEN 'INITIAL CASH'
                WHEN 101 THEN 'MANUAL'
            END
        WHEN crt.config_payment_method_id IS NOT NULL THEN 
                CASE crt.config_payment_method_id
                WHEN 1 THEN 'CHEQUE'
                WHEN 2 THEN 'COUPON'
                WHEN 3 THEN 'GREAT START REWARD (PT)'
                WHEN 4 THEN 'CASH VOUCHER'
                WHEN 5 THEN 'VISA AND MASTER BBL'
                WHEN 6 THEN 'VISA AND MASTER KBANK'
                WHEN 7 THEN 'VISA AND MASTER KTC'
                WHEN 8 THEN 'AMEX'
                WHEN 9 THEN 'DINERS'
                WHEN 10 THEN 'BANGKOK BAK 4 MONTHS'
                WHEN 11 THEN 'BANGKOK BANK 6 MONTHS'
                WHEN 12 THEN 'UOB 4 MONTHS'
                WHEN 13 THEN 'UOB 6 MONTHS'
                WHEN 14 THEN 'ZONE BELT REDEMPTION'
                WHEN 15 THEN 'KBANK 4 MONTHS'
                WHEN 16 THEN 'KBANK 6 MONTHS'
                WHEN 17 THEN 'KBANK 10 MONTHS'
                WHEN 18 THEN 'KBANK QR'
                WHEN 19 THEN 'E-COUPON'
                WHEN 20 THEN 'KTB 4 MONTHS'
                WHEN 21 THEN 'KTB 6 MONTHS'
                WHEN 22 THEN 'CITIBANK 4 MONTHS'
                WHEN 23 THEN 'CITIBANK 6 MONTHS'
                WHEN 24 THEN 'SCB 4 MONTHS'
                WHEN 25 THEN 'SCB 6 MONTHS'
                WHEN 26 THEN 'E-Wallet Line pay'
                WHEN 27 THEN 'JOL SALES'
                WHEN 28 THEN 'CREDIT CARD POINT REWARD'
                WHEN 29 THEN 'KBANK GATEWAY '
                WHEN 30 THEN 'KBANK GATEWAY 4 MONTHS'
                WHEN 31 THEN 'KBANK GATEWAY 6 MONTHS'
                WHEN 32 THEN 'KBANK GATEWAY 10 MONTHS'                
                WHEN 33 THEN 'SCB 5 MONTHS'
                WHEN 34 THEN 'Transfer to BBL'
                WHEN 35 THEN 'Transfer to KBANK'
                WHEN 36 THEN 'Transfer to KTB'
                WHEN 37 THEN 'Transfer to SCB'                                                                                          
                WHEN 38 THEN 'E-Wallet True money'  
                WHEN 39 THEN 'E-Wallet Alipay plus' 
                END                                                 
        WHEN crt.CRTTYPE IS NOT NULL THEN
                CASE crt.CRTTYPE
                WHEN 1 THEN 'CASH'
                WHEN 2 THEN 'CHANGE'
                WHEN 3 THEN 'RETURN ON CREDIT'
                WHEN 4 THEN 'PAYOUT CASH'
                WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
                WHEN 6 THEN 'DEBIT CARD'
                WHEN 7 THEN 'CREDIT CARD'
                WHEN 8 THEN 'DEBIT OR CREDIT CARD'
                WHEN 9 THEN 'GIFT CARD'
                WHEN 10 THEN 'CASH ADJUSTMENT'
                WHEN 11 THEN 'CASH TRANSFER'
                WHEN 12 THEN 'PAYMENT AR'
                WHEN 13 THEN 'CONFIG PAYMENT METHOD'
                WHEN 14 THEN 'CASH REGISTER PAYOUT'
                WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
                WHEN 16 THEN 'CLOSING CASH ADJUST'
                WHEN 17 THEN 'VOUCHER'
                WHEN 18 THEN 'PAYOUT CREDIT CARD'
                WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
                WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
                WHEN 21 THEN 'TRANSFER BACK CASH COINS'
                WHEN 22 THEN 'INSTALLMENT PLAN'
                WHEN 100 THEN 'INITIAL CASH'
                WHEN 101 THEN 'MANUAL'
            END     
        ELSE
                'CREDIT NOTE'       
    END AS "Payment Type",
    CURRENT_DATE - longtodatec(art.entry_time,art.center)::DATE AS "Days Since Paid",
    empp.fullname                                               AS "Operator",
    art.amount / 1.07 AS "Overpayment excluding TAX",
    art.amount * 0.07 / 1.07 AS "Overpayment TAX amount" ,
    art.amount AS "Overpayment Total"  
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
AND s.state IN (2,4,8)
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
    evolutionwellness.centers emppc
ON
    emppc.id = empp.center
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
    evolutionwellness.cashregistertransactions crt
ON  
    crt.artranscenter = art.center
AND crt.artransid = art.id
AND crt.artranssubid = art.subid
LEFT JOIN
    evolutionwellness.credit_notes cn
ON
    cn.center = art.ref_center
AND cn.id = art.ref_id
AND art.ref_type = 'CREDIT_NOTE'
JOIN 
    params
    ON params.center_id = art.center
WHERE
    art.amount > 0
AND p.center IN (:Scope)
AND p.sex != 'C'
AND art.entry_time BETWEEN params.FromDate AND params.ToDate