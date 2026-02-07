-- exclude free credit notes
WITH
    RECURSIVE centers_in_area AS
    (
        SELECT
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
    (
        SELECT
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
            1,2
    )
  , scope_center AS
    (
        SELECT
            'A'               AS SCOPE_TYPE
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
    (
        SELECT
            center_id
          , (xpath('//attribute/@id',xml_element))[1]::text::INTEGER     AS id
          , (xpath('//attribute/@name',xml_element))[1]::text            AS name
          , (xpath('//attribute/@globalAccountId',xml_element))[1]::text AS globalAccountId
        FROM
            (
                SELECT
                    center_id
                  , unnest(xpath('//attribute',xmlparse(document convert_from(mimevalue, 'UTF-8'))
                    )) AS xml_element
                FROM
                    (
                        SELECT
                            a.name
                          , sc.center_id
                          , sys.mimevalue
                          , sc.level
                          , MAX(sc.LEVEL) over (partition BY sc.CENTER_ID) AS maxlevel
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
  , params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                       AS center
          , datetolongc($$from_date$$::DATE::VARCHAR,c.id)                  AS from_date_long
          , datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
          , $$from_date$$::DATE                                             AS from_date
          , $$to_date$$::DATE                                             AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
  , credit_lines AS
    (
        SELECT
            cl.center||'cred'||cl.id||'cnl'||cl.subid AS cl_id
          , COALESCE(crt.center,cl.center)            AS center
          , cn.payer_center                 AS person_center
          , cn.payer_id                     AS person_id
          , cl.total_amount                 AS "Refund Gross Amount"
          , cl.total_amount - cl.net_amount AS "Refund Tax Amount"
          , cl.net_amount                   AS "Refund Net Amount"
          , CASE
                WHEN crt.center IS NULL
                THEN 'Refund - Account'
                ELSE 'Refund - Cash'
            END AS "Tender Type"
          , string_agg(COALESCE(icpm.name, CASE icrt.CRTTYPE
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
            END),', ')               AS "Original Payment Tender Type"
          , pr.center||'prod'||pr.id AS "Item"
          , pr.name                  AS "Item Description"
          , rac.name                 AS "Ledger Group"
          , rac.external_id          AS "Ledger Group Code"
          , CASE cl.REASON
                WHEN 0
                THEN 'Unknown'
                WHEN 1
                THEN 'Default'
                WHEN 2
                THEN 'Freeze'
                WHEN 3
                THEN 'PersonTypeChange'
                WHEN 4
                THEN 'Upgrade'
                WHEN 5
                THEN 'Downgrade'
                WHEN 6
                THEN 'Transfer'
                WHEN 7
                THEN 'Regret'
                WHEN 8
                THEN 'StopMembership'
                WHEN 9
                THEN 'Autorenew'
                WHEN 10
                THEN 'SavedFreeDays'
                WHEN 11
                THEN 'PayoutMembership'
                WHEN 12
                THEN 'ChangeMembership'
                WHEN 13
                THEN 'DcStopMembership'
                WHEN 14
                THEN 'WrongSale'
                WHEN 15
                THEN 'ProductReturned'
                WHEN 16
                THEN 'FreeCreditline'
                WHEN 17
                THEN 'ManualPriceAdjust'
                WHEN 18
                THEN 'Sanction'
                WHEN 19
                THEN 'ChargedMessageUndeliverable'
                WHEN 20
                THEN 'DcSendAgency'
                WHEN 21
                THEN 'ManualRenew'
                WHEN 22
                THEN 'PrivilegeUsageCancelled'
                WHEN 23
                THEN 'Documentation'
                WHEN 24
                THEN 'WriteOff'
                WHEN 25
                THEN 'PaymentCollectionFeeReversed'
                WHEN 26
                THEN 'ApplyStep'
                WHEN 27
                THEN 'SaleOnAccount'
                WHEN 28
                THEN 'ReminderFee'
                WHEN 29
                THEN 'MemberCardReturned'
                WHEN 30
                THEN 'MemberShipSale'
                WHEN 31
                THEN 'ShopSale'
                WHEN 32
                THEN 'ChangeStartDate'
                WHEN 33
                THEN 'BuyoutClipcard'
                WHEN 34
                THEN 'FamilyPersonTypeChange'
                WHEN 35
                THEN 'FamilySubscriptionChange'
                WHEN 36
                THEN 'Reassign'
                WHEN 37
                THEN 'RegretClipcard'
                ELSE 'Undefined'
            END                                        AS "Refund Reason"
          , cn.coment                                  AS "Notes"
          , longtodatec(i.entry_time,i.center)         AS "Charge Date"
          , longtodatec(cn.entry_time,cn.center)::DATE AS "Refund Processed Date"
          , cn.employee_center
          , cn.employee_id
          , icrt.center AS payment_source_center
        FROM
            evolutionwellness.credit_note_lines_mt cl
        JOIN
            params
        ON
            params.center = cl.center
        JOIN
            evolutionwellness.credit_notes cn
        ON
            cn.center = cl.center
        AND cn.id = cl.id
        JOIN
            evolutionwellness.invoices i
        ON
            i.center = cl.invoiceline_center
        AND i.id = cl.invoiceline_id
        JOIN
            evolutionwellness.invoice_lines_mt il
        ON
            il.center = cl.invoiceline_center
        AND il.id = cl.invoiceline_id
        AND il.subid = cl.invoiceline_subid
        LEFT JOIN
            evolutionwellness.cashregistertransactions crt
        ON
            crt.paysessionid = cn.paysessionid
        AND (
                crt.customercenter = cl.person_center
            AND crt.customerid = cl.person_id
            OR  crt.customercenter IS NULL)
        AND crt.crttype NOT IN (10,11,15,16,20)
        LEFT JOIN
            evolutionwellness.cashregisters cr
        ON
            cr.center = crt.crcenter
        AND cr.id = crt.crid
        LEFT JOIN
            center_config_payment_method_id cpm
        ON
            cpm.center_id = crt.center
        AND crt.config_payment_method_id = cpm.id
        LEFT JOIN
            evolutionwellness.cashregistertransactions icrt
        ON
            icrt.paysessionid = i.paysessionid
        AND icrt.customercenter = il.person_center
        AND icrt.customerid = il.person_id
        AND icrt.crttype NOT IN (10,11,15,16,20)
        LEFT JOIN
            center_config_payment_method_id icpm
        ON
            icrt.center =icpm.center_id
        AND icrt.config_payment_method_id = icpm.id
        JOIN
            evolutionwellness.products pr
        ON
            pr.center = cl.productcenter
        AND pr.id = cl.productid
        JOIN
            evolutionwellness.product_account_configurations pac
        ON
            pac.id = pr.product_account_config_id
        LEFT JOIN
            accounts rac
        ON
            rac.globalid = pac.refund_account_globalid
        AND rac.center = pr.center
        LEFT JOIN
            credit_note_line_vat_at_link vat_link
        ON
            vat_link.credit_note_line_center = cl.center
        AND vat_link.credit_note_line_id = cl.id
        AND vat_link.credit_note_line_subid = cl.subid
        LEFT JOIN
            vat_types vat
        ON
            vat.center = cl.center
        AND vat.id = vat_link.id
        WHERE
            cn.entry_time BETWEEN params.from_date_long AND params.to_date_long
        AND cl.total_amount != 0
        GROUP BY
            cl.center
          , cl.id
          , cl.subid
          , cl.total_amount
          , cl.total_amount - cl.net_amount
          , cl.net_amount
          , crt.center
          , pr.center||'prod'||pr.id
          , pr.name
          , rac.name
          , rac.external_id
          , cl.REASON
          , cn.coment
          , longtodatec(i.entry_time,i.center)
          , longtodatec(cn.entry_time,cn.center)
          , cn.payer_center  
          , cn.payer_id
          , cn.employee_center
          , cn.employee_id
          , icrt.center
    )
  , payout_lines AS
    (
        SELECT
            crt.artranscenter||'art'||crt.artransid||'ln'||crt.artranssubid AS cl_id
          , crt.customercenter                                              AS person_center
          , crt.customerid                                                  AS person_id
          , crt.amount                                                      AS
            "Refund Gross Amount"
          , NULL::NUMERIC                               AS "Refund Tax Amount"
          , NULL::NUMERIC                               AS "Refund Net Amount"
          , 'Refund - Cash Out'                         AS "Tender Type"
          , NULL::text                                  AS "Original Payment Tender Type"
          , NULL::text                                  AS "Item"
          , NULL::text                                  AS "Item Description"
          , acc.name                                    AS "Ledger Group"
          , acc.external_id                             AS "Ledger Group Code"
          , NULL::text                                  AS "Refund Reason"
          , art.text                                    AS "Notes"
          , NULL::DATE                                  AS "Charge Date"
          , longtodatec(crt.transtime,crt.center)::DATE AS "Refund Processed Date"
          , crt.employeecenter                          AS employee_center
          , crt.employeeid                              AS employee_id
          , crt.center
          , crt.center AS payment_source_center
        FROM
            evolutionwellness.cashregistertransactions crt
        JOIN
            evolutionwellness.ar_trans art
        ON
            art.center = crt.artranscenter
        AND art.id = crt.artransid
        AND crt.artranssubid = art.subid
        JOIN
            evolutionwellness.account_trans act
        ON
            act.center = art.ref_center
        AND act.id = art.ref_id
        AND act.subid = art.ref_subid
        AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
            evolutionwellness.accounts acc
        ON
            acc.center = act.credit_accountcenter
        AND acc.id = act.credit_accountid
        JOIN
            params
        ON
            params.center = art.center
        WHERE
            crt.artranscenter IS NOT NULL
        AND crt.crttype = 4
        AND crt.transtime BETWEEN params.from_date_long AND params.to_date_long
    )
  , art_refund_lines AS
    (
        SELECT
            art.center||'art'||art.id||'ln'||art.subid   AS cl_id
          , ar.customercenter                            AS person_center
          , ar.customerid                                AS person_id
          , art.amount                                   AS "Refund Gross Amount"
          , NULL::NUMERIC                                AS "Refund Tax Amount"
          , NULL::NUMERIC                                AS "Refund Net Amount"
          , 'Refund - AR Trans Payout'                   AS "Tender Type"
          , NULL::text                                   AS "Original Payment Tender Type"
          , NULL::text                                   AS "Item"
          , NULL::text                                   AS "Item Description"
          , acc.name                                     AS "Ledger Group"
          , acc.external_id                              AS "Ledger Group Code"
          , NULL::text                                   AS "Refund Reason"
          , art.text                                     AS "Notes"
          , NULL::DATE                                   AS "Charge Date"
          , longtodatec(art.entry_time,art.center)::DATE AS "Refund Processed Date"
          , art.employeecenter                           AS employee_center
          , art.employeeid                               AS employee_id
          , art.center
          , art.center AS payment_source_center
        FROM
            evolutionwellness.ar_trans art
        JOIN
            params
        ON
            params.center = art.center
        JOIN
            evolutionwellness.account_receivables ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        JOIN
            evolutionwellness.account_trans act
        ON
            act.center = art.ref_center
        AND act.id = art.ref_id
        AND act.subid = art.ref_subid
        AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
            evolutionwellness.accounts acc
        ON
            acc.center = act.credit_accountcenter
        AND acc.id = act.credit_accountid
        JOIN
            centers c
        ON
            c.id = acc.center
        WHERE
            art.amount < 0
        AND ((
                    acc.external_id = '323101-00'
                AND c.country = 'ID')
            OR  (
                    c.country IN ('MY'
                                ,'SG')
                AND acc.external_id LIKE '258001-%')
            OR  (
                    c.country = 'PH'
                AND acc.external_id = '258001-01')
            OR  (
                    c.country = 'TH'
                AND acc.external_id = '323101-00'))
        AND art.entry_time BETWEEN params.from_date_long AND params.to_date_long
    )
  , res AS
    (
        SELECT
            cl_id                 AS "Event ID"
          , cou.name              AS "Division"
          , a.name                AS "Region"
          , c.name                AS "Club"
          , c.id                  AS "Club Number"
          , c.external_id         AS "Club Code"
          , cp.external_id        AS "Member Number"
          , p.center||'p'||p.id   AS "Person Key"
          , cp.center||'p'||cp.id AS "Current Person Key"
          , params.to_date        AS "Date"
          , staff.fullname        AS "Operator"
          , cl."Refund Gross Amount"
          , cl."Refund Tax Amount"
          , cl."Refund Net Amount"
          , cl."Tender Type"
          , cl."Original Payment Tender Type"
          , cl."Item"
          , cl."Item Description"
          , cl."Ledger Group"
          , cl."Ledger Group Code"
          , cl."Refund Reason"
          , cl."Notes"
          , cl."Charge Date"
          , cl."Refund Processed Date"
          , c1.name                                          AS "Payment Source"
          , params.to_date - "Charge Date"                   AS "Fee Age (Days)"
          , NULL                                             AS "Payment Type"
          , cl."Refund Gross Amount"                         AS "Charge Amount"
          , NULL                                             AS "Current Written Off"
          , cl."Refund Gross Amount"                         AS "Total Refunded"
          , NULL                                             AS "Total Paid (Billing)"
          , NULL                                             AS "Total Paid (Club)"
          , NULL                                             AS "Total Paid (Head Office)"
          , NULL                                             AS "Total Paid"
          , NULL                                             AS "Outstanding"
          , COALESCE(channel_pref.txtvalue = 'email',false)  AS "Is Email Preferred"
          , email.txtvalue                                   AS "Email Address"
          , COALESCE(channel_pref.txtvalue = 'letter',false) AS "Is Letter Preferred"
          , p.city                                           AS "Address Name/Number"
          , p.address1                                       AS "Address Line 1"
          , p.address2                                       AS "Address Line 2"
          , p.address3                                       AS "Address Line 3"
          , p.zipcode                                        AS "PostCode"
          , NULL                                             AS "Gone Away"
          , p.firstname                                      AS "First Name"
          , p.lastname                                       AS "Last Name"
        FROM
            (
                SELECT
                    cl_id
                  , center
                  , person_center
                  , person_id
                  , "Refund Gross Amount"
                  , "Refund Tax Amount"
                  , "Refund Net Amount"
                  , "Tender Type"
                  , "Original Payment Tender Type"
                  , "Item"
                  , "Item Description"
                  , "Ledger Group"
                  , "Ledger Group Code"
                  , "Refund Reason"
                  , "Notes"
                  , "Charge Date"
                  , "Refund Processed Date"
                  , employee_center
                  , employee_id
                  , payment_source_center
                FROM
                    credit_lines
                UNION ALL
                SELECT
                    cl_id
                  , center
                  , person_center
                  , person_id
                  , "Refund Gross Amount"
                  , "Refund Tax Amount"
                  , "Refund Net Amount"
                  , "Tender Type"
                  , "Original Payment Tender Type"
                  , "Item"
                  , "Item Description"
                  , "Ledger Group"
                  , "Ledger Group Code"
                  , "Refund Reason"
                  , "Notes"
                  , "Charge Date"
                  , "Refund Processed Date"
                  , employee_center
                  , employee_id
                  , payment_source_center
                FROM
                    payout_lines
                UNION ALL
                SELECT
                    cl_id
                  , center
                  , person_center
                  , person_id
                  , "Refund Gross Amount"
                  , "Refund Tax Amount"
                  , "Refund Net Amount"
                  , "Tender Type"
                  , "Original Payment Tender Type"
                  , "Item"
                  , "Item Description"
                  , "Ledger Group"
                  , "Ledger Group Code"
                  , "Refund Reason"
                  , "Notes"
                  , "Charge Date"
                  , "Refund Processed Date"
                  , employee_center
                  , employee_id
                  , payment_source_center
                FROM
                    art_refund_lines ) cl
        JOIN
            centers c
        ON
            c.id = cl.center
        JOIN
            params
        ON
            PARAMS.center = c.id
        JOIN
            evolutionwellness.area_centers ac
        ON
            ac.center = cl.center
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
            persons p
        ON
            p.center = cl.person_center
        AND p.id = cl.person_id
        LEFT JOIN
            evolutionwellness.employees emp
        ON
            emp.center = cl.employee_center
        AND emp.id = cl.employee_id
        LEFT JOIN
            evolutionwellness.persons staff
        ON
            staff.center = emp.personcenter
        AND staff.id = emp.personid
        LEFT JOIN
            evolutionwellness.person_ext_attrs email
        ON
            email.personcenter= p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'
        LEFT JOIN
            evolutionwellness.person_ext_attrs channel_pref
        ON
            channel_pref.personcenter= p.center
        AND channel_pref.personid = p.id
        AND channel_pref.name = '_eClub_DefaultMessaging'
        LEFT JOIN
            evolutionwellness.person_ext_attrs letter_allowed
        ON
            letter_allowed.personcenter= p.center
        AND letter_allowed.personid = p.id
        AND letter_allowed.name = '_eClub_AllowedChannelLetter'
        JOIN
            persons cp
        ON
            cp.center = p.transfers_current_prs_center
        AND cp.id = p.transfers_current_prs_id
        LEFT JOIN
            centers c1
        ON
            c1.id = cl.payment_source_center
    )
SELECT
    *
FROM
    res