-- every POS sale in the period + evey pay into account allocated where the payment was after the
-- sale
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
    params AS materialized
    (
        SELECT
                DATE_TRUNC('month', t1.todaysdate - INTERVAL '1 months') AS from_date,
                DATE_TRUNC('month', t1.todaysdate) - INTERVAL '1 day' AS to_date,
                CAST(DATETOLONGC(TO_CHAR(DATE_TRUNC('month', t1.todaysdate - INTERVAL '1 months'),'YYYY-MM-DD'), t1.id) AS BIGINT) AS from_date_long,
                CAST(DATETOLONGC(TO_CHAR(DATE_TRUNC('month', t1.todaysdate),'YYYY-MM-DD'), t1.id)-1 AS BIGINT) to_date_long,
                t1.id AS center
        FROM
        (
                SELECT
                        TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS todaysdate,
                        c.id
                FROM 
                        CENTERS c
                WHERE
                        c.id IN ($$scope$$)
        ) t1
    )        
    ,
    sell_on_behalf AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    ise.invoice_center,
                    ise.invoice_id,
                    sales_person.fullname,
                    row_number() over (partition BY ise.invoice_center, ise.invoice_id ORDER BY
                    ise.start_time DESC) rnk
                FROM
                    params,
                    invoice_sales_employee ise
                LEFT JOIN
                    EMPLOYEES sales_staff
                ON
                    sales_staff.center = ise.sales_employee_center
                AND sales_staff.id = ise.sales_employee_id
                LEFT JOIN
                    PERSONS sales_person
                ON
                    sales_person.center = sales_staff.personcenter
                AND sales_person.ID = sales_staff.personid )
        WHERE
            rnk = 1
    )
    ,
    sale_line AS
    (
        SELECT
            i.paysessionid,
            i.center,
            i.id,
            i.entry_time,
            i.center||'inv'||i.id                           AS "Sale ID",
            il.CENTER || 'inv' || il.ID || 'ln' || il.SUBID AS "Sale Line ID",
            CASE
                WHEN p.center IS NULL
                THEN 'Cash Sales'
                ELSE cp.external_id
            END AS "Member Number",
            CASE
                WHEN p.center IS NOT NULL
                THEN p.center||'p'||p.id
            END AS "Person Key",
            CASE
                WHEN p.center IS NOT NULL
                THEN cp.center||'p'||cp.id
            END                                                             AS "Current Person Key",
            COALESCE(sob.fullname, staff.fullname)                                 AS "Operator",
            TO_CHAR(longtodatec(i.entry_time,i.center),'yyyy-MM-dd hh24:mi')::DATE AS "Charge Date"
            ,
            TO_CHAR(longtodatec(i.entry_time,999),'yyyy-MM-dd hh24:mi')::text AS "Head Office Time"
            ,
            TO_CHAR(longtodatec(i.entry_time,crt_center.center),'yyyy-MM-dd hh24:mi')::text AS
            "Club Time",
            il.quantity                     AS "Quantity",
            pr.center||'prod'||pr.id        AS "Item",
            pr.name                         AS "Item Description",
            rac.name                        AS "Ledger Group",
            rac.external_id                 AS "Ledger Group Code",
            il.total_amount                 AS "Total Sale Amount",
            il.total_amount - il.net_amount AS "Total Tax Amount",
            cl.id IS NOT NULL               AS "Refunded",
            cn.entry_time                   AS refund_entry_time,
            CASE cl.REASON
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
                ELSE cl.REASON::text
            END               AS "Refund Reason",
            cn.coment         AS "Refund Description",
            crt_center.center AS crt_center,
            i.payer_center,
            i.payer_id
        FROM
            evolutionwellness.invoice_lines_mt il
        JOIN
            evolutionwellness.invoices i
        ON
            i.center = il.center
        AND i.id = il.id
        JOIN
            (
                SELECT DISTINCT
                    paysessionid,
                    crt.customercenter,
                    crt.customerid,
                    center
                FROM
                    evolutionwellness.cashregistertransactions crt
                WHERE
                    crt.center IN ($$scope$$)
                AND crt.crttype NOT IN (4,10,11,15,16,20 ) ) crt_center
        ON
            crt_center.paysessionid = i.paysessionid
        AND ((
                    crt_center.customercenter = i.payer_center
                AND crt_center.customerid = i.payer_id)
            OR  crt_center.customercenter IS NULL)
        JOIN
            evolutionwellness.products pr
        ON
            pr.center = il.productcenter
        AND pr.id = il.productid
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
            evolutionwellness.credit_note_lines_mt cl
        ON
            cl.invoiceline_center = il.center
        AND cl.invoiceline_id = il.id
        AND cl.invoiceline_subid = il.subid
        LEFT JOIN
            evolutionwellness.credit_notes cn
        ON
            cn.center = cl.center
        AND cn.id = cl.id
        LEFT JOIN
            persons p
        ON
            p.center = i.payer_center
        AND p.id = i.payer_id
        JOIN
            evolutionwellness.employees emp
        ON
            emp.center = i.employee_center
        AND emp.id = i.employee_id
        JOIN
            evolutionwellness.persons staff
        ON
            staff.center = emp.personcenter
        AND staff.id = emp.personid
        LEFT JOIN
            sell_on_behalf sob
        ON
            sob.invoice_center = i.center
        AND sob.invoice_id = i.id
        LEFT JOIN
            persons cp
        ON
            cp.center = p.transfers_current_prs_center
        AND cp.id = p.transfers_current_prs_id
        JOIN
            params
        ON
            params.center = crt_center.center
        WHERE
            (
                i.entry_time BETWEEN params.from_date_long AND params.to_date_long )
    )
    ,
    shifts AS
    (
        SELECT DISTINCT
            crl.cash_register_center,
            crl.cash_register_id,
            CASE
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN longtodatec(log_time,crl.cash_register_center)
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN longtodatec(lag(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC),crl.cash_register_center)
            END AS register_close,
            CASE
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN longtodatec(log_time,crl.cash_register_center)
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN longtodatec(lead(log_time) over (partition BY crl.cash_register_center ,
                    crl.cash_register_id ORDER BY log_time DESC),crl.cash_register_center )
            END AS register_open,
            CASE
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN log_time
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN lag(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC)
            END AS register_close_long,
            CASE
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN log_time
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN lead(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC)
            END AS register_open_long
        FROM
            evolutionwellness.cash_register_log crl
        WHERE
            log_type IN('CLOSE_CASH_REGISTER',
                        'OPEN_CASH_REGISTER')
    )
    ,
    sale_payment AS
    (
        SELECT
            i.paysessionid,
            "Member Number",
            "Person Key",
            "Current Person Key",
            "Operator",
            "Charge Date",
            "Head Office Time",
            COALESCE(cpm.name,
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
            END ) AS "Tender Type",
            CASE
                WHEN crttype = 2
                THEN crt.amount*-1
                ELSE crt.amount
            END                      AS "Tender Amount",
            shifts.register_open     AS "Shift Start Time" ,
            shifts.register_close    AS "Shift End Time",
            crt.center||'cr'||crt.id AS "Workstation",
            crt.center               AS crt_center,
            crt.transtime            AS entry_time
        FROM
            (
                SELECT DISTINCT
                    paysessionid,
                    payer_center,
                    payer_id,
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time"
                FROM
                    sale_line) i
        JOIN
            evolutionwellness.cashregistertransactions crt
        ON
            crt.paysessionid = i.paysessionid
        AND ((
                    crt.customercenter = i.payer_center
                AND crt.customerid = i.payer_id)
            OR  crt.customercenter IS NULL)
        LEFT JOIN
            center_config_payment_method_id cpm
        ON
            cpm.center_id = crt.center
        AND crt.config_payment_method_id = cpm.id
        LEFT JOIN
            shifts
        ON
            crt.center = shifts.cash_register_center
        AND crt.id = shifts.cash_register_id
        AND crt.transtime > shifts.register_open_long
        AND (
                crt.transtime < shifts.register_close_long
            OR  shifts.register_close_long IS NULL)
        WHERE
            crt.crttype NOT IN (4,10,11,15,16,20 )
    )
    ,
    pay_into_account_lines AS
    (
        SELECT
            crt.paysessionid,
            cp.external_id                                                     AS "Member Number",
            p.center||'p'||p.id                                                AS "Person Key",
            cp.center||'p'||cp.id                                           AS "Current Person Key",
            staff.fullname                                     AS "Operator",
            longtodatec(crt.transtime, crt.center)::DATE                       AS "Charge Date",
            TO_CHAR(longtodatec(crt.transtime,999),'yyyy-MM-dd hh24:mi')::text AS
            "Head Office Time",
            TO_CHAR(longtodatec(crt.transtime,crt.center),'yyyy-MM-dd hh24:mi')::text AS
            "Club Time",
            COALESCE(cpm.name,
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
            END ) AS "Tender Type",
            CASE
                WHEN crttype = 2
                THEN crt.amount*-1
                ELSE crt.amount
            END                      AS "Tender Amount",
            shifts.register_open     AS "Shift Start Time" ,
            shifts.register_close    AS "Shift End Time",
            crt.center||'cr'||crt.id AS "Workstation",
            crt.center               AS crt_center,
            crt.id                   AS crt_id,
            crt.subid                AS crt_subid,
            crt.transtime            AS entry_time,
            COALESCE(paarm.amount,0) AS allocated_amount,
            CASE
                WHEN npart.ref_type = 'INVOICE'
                THEN npart.ref_center||'inv'||npart.ref_id
                WHEN npart.ref_type = 'ACCOUNT_TRANS'
                THEN npart.ref_center||'acc'||npart.ref_id||'tr'||npart.ref_subid
            END AS line_ref
        FROM
            params
        JOIN
            evolutionwellness.cashregistertransactions crt
        ON
            crt.center = params.center
        JOIN
            evolutionwellness.ar_trans art
        ON
            art.center = crt.artranscenter
        AND art.id = crt.artransid
        AND art.subid = crt.artranssubid
        AND art.text LIKE 'Payment into account%'
            /*JOIN
            evolutionwellness.art_match arm
            ON
            art.center = arm.art_paying_center
            AND art.id = arm.art_paying_id
            AND art.subid= arm.art_paying_subid
            AND arm.cancelled_time IS NULL
            JOIN
            evolutionwellness.ar_trans ncart
            ON
            arm.art_paid_center = ncart.center
            AND arm.art_paid_id= ncart.id
            AND arm.art_paid_subid = ncart.subid
            JOIN
            evolutionwellness.ar_trans part
            ON
            ncart.ref_center = part.ref_center
            AND ncart.ref_id = part.ref_id
            AND ncart.ref_subid = part.ref_subid
            AND part.ref_type = 'ACCOUNT_TRANS'
            AND ncart.ref_type = 'ACCOUNT_TRANS'
            AND ncart.id != part.id*/
        LEFT JOIN
            evolutionwellness.art_match paarm
        ON
            art.center = paarm.art_paying_center
        AND art.id = paarm.art_paying_id
        AND art.subid= paarm.art_paying_subid
        AND paarm.cancelled_time IS NULL
        LEFT JOIN
            evolutionwellness.ar_trans npart
        ON
            paarm.art_paid_center = npart.center
        AND paarm.art_paid_id= npart.id
        AND paarm.art_paid_subid = npart.subid
        AND npart.entry_time < art.entry_time
        LEFT JOIN
            persons p
        ON
            p.center = crt.customercenter
        AND p.id = crt.customerid
        LEFT JOIN
            persons cp
        ON
            cp.center = p.transfers_current_prs_center
        AND cp.id = p.transfers_current_prs_id
        JOIN
            evolutionwellness.employees emp
        ON
            emp.center = crt.employeecenter
        AND emp.id = crt.employeeid
        JOIN
            evolutionwellness.persons staff
        ON
            staff.center = emp.personcenter
        AND staff.id = emp.personid
        LEFT JOIN
            center_config_payment_method_id cpm
        ON
            cpm.center_id = crt.center
        AND crt.config_payment_method_id = cpm.id
        LEFT JOIN
            shifts
        ON
            crt.center = shifts.cash_register_center
        AND crt.id = shifts.cash_register_id
        AND crt.transtime > shifts.register_open_long
        AND (
                crt.transtime < shifts.register_close_long
            OR  shifts.register_close_long IS NULL)
        WHERE
            crt.crttype NOT IN (4,10,11,15,16,20 )
        AND crt.crttype NOT IN (5,
                                12)
        AND crt.transtime BETWEEN params.from_date_long AND params.to_date_long
        AND crt.artranscenter IS NOT NULL
    )
    ,
    pay_into_account_payment_lines AS
    (
        SELECT DISTINCT
            paysessionid,
            crt_center,
            crt_id,
            crt_subid,
            "Member Number",
            "Person Key",
            "Current Person Key",
            "Operator",
            "Charge Date",
            "Head Office Time",
            "Club Time",
            "Tender Type",
            "Tender Amount",
            "Shift Start Time",
            "Shift End Time" ,
            "Workstation"
        FROM
            pay_into_account_lines
    )
    /*SELECT
    *
    FROM
    pay_into_account_lines
    WHERE
    "Person Key" = '117p1938';*/
    ,
    res AS
    (
        SELECT
            line_type AS "Line Type",
            line.paysessionid,
            "Sale ID",
            "Sale Line ID",
            cou.name      AS "Division",
            a.name        AS "Region",
            c.name        AS "Club",
            c.id          AS "Club Number",
            c.external_id AS "Club Code",
            "Member Number",
            "Person Key",
            "Current Person Key",
            "Operator",
            "Charge Date",
            MAX("Shift Start Time") over (partition BY line.paysessionid) AS "Shift Start Time" ,
            MAX("Shift End Time") over (partition BY line.paysessionid)   AS "Shift End Time" ,
            "Head Office Time",
            "Club Time" ,
            MAX("Workstation") over (partition BY line.paysessionid) AS "Workstation" ,
            "Item",
            "Item Description",
            "Ledger Group",
            "Ledger Group Code",
            "Refunded",
            "Refund Reason",
            "Refund Description",
            longtodatec(refund_entry_time,line.center)::text AS "Refund Time",
            "Quantity",
            "Total Sale Amount",
            "Total Tax Amount",
            "Tender Type",
            CASE line_type
                WHEN 'Total Sale'
                THEN SUM("Tender Amount") over (partition BY line.paysessionid)
                WHEN '   Payment Line'
                THEN "Tender Amount"
            END AS "Tender Amount"
        FROM
            (
                SELECT
                    'Total Sale' AS line_type,
                    sale.paysessionid,
                    1          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    NULL::text               AS "Club Time",
                    NULL::text               AS "Item",
                    NULL::text               AS "Item Description",
                    NULL::text               AS "Ledger Group",
                    NULL::text               AS "Ledger Group Code",
                    NULL::INTEGER            AS "Quantity",
                    SUM("Total Sale Amount") AS "Total Sale Amount",
                    SUM("Total Tax Amount")  AS "Total Tax Amount",
                    NULL::text               AS "Tender Type",
                    NULL::NUMERIC            AS "Tender Amount",
                    NULL::TIMESTAMP          AS "Shift Start Time",
                    NULL::TIMESTAMP          AS "Shift End Time",
                    NULL::text               AS "Workstation",
                    NULL::bigint             AS refund_entry_time,
                    NULL::BOOLEAN            AS "Refunded",
                    NULL:: text              AS "Refund Reason",
                    NULL::text               AS "Refund Description",
                    crt_center               AS center
                FROM
                    sale_line sale
                GROUP BY
                    paysessionid,
                    crt_center,
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time"
                UNION ALL
                SELECT
                    '   Detail Line' AS line_type,
                    paysessionid ,
                    2 AS ordercol,
                    "Sale ID",
                    "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    "Club Time",
                    "Item",
                    "Item Description",
                    "Ledger Group",
                    "Ledger Group Code",
                    "Quantity",
                    "Total Sale Amount",
                    "Total Tax Amount",
                    NULL::text      AS "Tender Type",
                    NULL::NUMERIC   AS "Tender Amount",
                    NULL::TIMESTAMP AS "Shift Start Time",
                    NULL::TIMESTAMP AS "Shift End Time",
                    NULL::text      AS "Workstation",
                    refund_entry_time,
                    "Refunded",
                    "Refund Reason",
                    "Refund Description",
                    crt_center
                FROM
                    sale_line
                UNION ALL
                SELECT
                    '   Payment Line' AS line_type,
                    paysessionid,
                    3          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    NULL::text    AS "Club Time",
                    NULL::text    AS "Item",
                    NULL::text    AS "Item Description",
                    NULL::text    AS "Ledger Group",
                    NULL::text    AS "Ledger Group Code",
                    NULL::INTEGER AS "Quantity",
                    NULL::NUMERIC AS "Total Sale Amount",
                    NULL::NUMERIC AS "Total Tax Amount",
                    "Tender Type",
                    "Tender Amount",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation",
                    NULL::bigint  AS refund_entry_time,
                    NULL::BOOLEAN AS "Refunded",
                    NULL::text    AS "Refund Reason",
                    NULL::text    AS "Refund Description",
                    crt_center    AS center
                FROM
                    sale_payment
                UNION ALL
                SELECT
                    'Total Sale' AS line_type,
                    paysessionid,
                    1          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    NULL::text            AS "Club Time",
                    NULL::text            AS "Item",
                    NULL::text            AS "Item Description",
                    NULL::text            AS "Ledger Group",
                    NULL::text            AS "Ledger Group Code",
                    NULL::INTEGER         AS "Quantity",
                    SUM(allocated_amount) AS "Total Sale Amount",
                    NULL::NUMERIC         AS "Total Tax Amount",
                    NULL::text            AS "Tender Type",
                    NULL::NUMERIC         AS "Tender Amount",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation",
                    NULL::bigint  AS refund_entry_time,
                    NULL::BOOLEAN AS "Refunded",
                    NULL::text    AS "Refund Reason",
                    NULL::text    AS "Refund Description",
                    crt_center    AS center
                FROM
                    pay_into_account_lines pia
                GROUP BY
                    paysessionid,
                    crt_center,
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation"
                UNION ALL
                SELECT
                    '   Detail Line' AS line_type,
                    paysessionid,
                    2          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    "Club Time",
                    line_ref              AS "Item",
                    'Pay into account'    AS "Item Description",
                    NULL::text            AS "Ledger Group",
                    NULL::text            AS "Ledger Group Code",
                    NULL::INTEGER         AS "Quantity",
                    SUM(allocated_amount) AS "Total Sale Amount",
                    NULL::NUMERIC         AS "Total Tax Amount",
                    NULL::text            AS "Tender Type",
                    NULL::NUMERIC         AS "Tender Amount",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation",
                    NULL::bigint  AS refund_entry_time,
                    NULL::BOOLEAN AS "Refunded",
                    NULL::text    AS "Refund Reason",
                    NULL::text    AS "Refund Description",
                    crt_center    AS center
                FROM
                    pay_into_account_lines pia
                GROUP BY
                    paysessionid,
                    crt_center,
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation",
                    "Club Time",
                    line_ref
                UNION ALL
                SELECT
                    '   Detail Line' AS line_type,
                    t1.paysessionid,
                    2          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    t1."Member Number",
                    t1."Person Key",
                    t1."Current Person Key",
                    t1."Operator",
                    t1."Charge Date",
                    t1."Head Office Time",
                    t1."Club Time",
                    NULL::text                                 AS "Item",
                    'Pay into account - overpayment'           AS "Item Description",
                    NULL::text                                 AS "Ledger Group",
                    NULL::text                                 AS "Ledger Group Code",
                    NULL::INTEGER                              AS "Quantity",
                    total_tender_amount-total_allocated_amount AS "Total Sale Amount",
                    NULL::NUMERIC                              AS "Total Tax Amount",
                    NULL::text                                 AS "Tender Type",
                    NULL::NUMERIC                              AS "Tender Amount",
                    t1."Shift Start Time",
                    t1."Shift End Time" ,
                    t1."Workstation",
                    NULL::bigint  AS refund_entry_time,
                    NULL::BOOLEAN AS "Refunded",
                    NULL::text    AS "Refund Reason",
                    NULL::text    AS "Refund Description",
                    t1.crt_center AS center
                FROM
                    (
                        SELECT
                            paysessionid,
                            "Member Number",
                            "Person Key",
                            "Current Person Key",
                            "Operator",
                            "Charge Date",
                            "Head Office Time",
                            "Club Time",
                            "Shift Start Time",
                            "Shift End Time" ,
                            "Workstation",
                            crt_center,
                            SUM("Tender Amount") AS total_tender_amount
                        FROM
                            pay_into_account_payment_lines
                        GROUP BY
                            paysessionid,
                            "Member Number",
                            "Person Key",
                            "Current Person Key",
                            "Operator",
                            "Charge Date",
                            "Head Office Time",
                            "Club Time",
                            "Shift Start Time",
                            "Shift End Time" ,
                            "Workstation",
                            crt_center ) t1
                LEFT JOIN
                    (
                        SELECT
                            paysessionid,
                            "Member Number",
                            "Person Key",
                            "Current Person Key",
                            "Operator",
                            "Charge Date",
                            "Head Office Time",
                            "Club Time",
                            "Shift Start Time",
                            "Shift End Time",
                            crt_center,
                            SUM(allocated_amount) AS total_allocated_amount
                        FROM
                            pay_into_account_lines pia
                        GROUP BY
                            paysessionid,
                            "Member Number",
                            "Person Key",
                            "Current Person Key",
                            "Operator",
                            "Charge Date",
                            "Head Office Time",
                            "Club Time",
                            "Shift Start Time",
                            "Shift End Time" ,
                            "Workstation",
                            crt_center )t2
                ON
                    t1.paysessionid = t2.paysessionid
                WHERE
                    total_tender_amount- total_allocated_amount != 0
                UNION ALL
                SELECT
                    '   Payment Line' AS line_type,
                    paysessionid,
                    3          AS ordercol,
                    NULL::text AS "Sale ID",
                    NULL::text AS "Sale Line ID",
                    "Member Number",
                    "Person Key",
                    "Current Person Key",
                    "Operator",
                    "Charge Date",
                    "Head Office Time",
                    NULL::text    AS "Club Time",
                    NULL::text    AS "Item",
                    NULL::text    AS "Item Description",
                    NULL::text    AS "Ledger Group",
                    NULL::text    AS "Ledger Group Code",
                    NULL::INTEGER AS "Quantity",
                    NULL::NUMERIC AS "Total Sale Amount",
                    NULL::NUMERIC AS "Total Tax Amount",
                    "Tender Type",
                    "Tender Amount",
                    "Shift Start Time",
                    "Shift End Time" ,
                    "Workstation",
                    NULL::bigint  AS refund_entry_time,
                    NULL::BOOLEAN AS "Refunded",
                    NULL::text    AS "Refund Reason",
                    NULL::text    AS "Refund Description",
                    crt_center    AS center
                FROM
                    pay_into_account_payment_lines ) line
        JOIN
            centers c
        ON
            c.id = line.center
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
            line.paysessionid,
            ordercol ASC
    )
    ,
    tst_reconcile AS
    (
        SELECT
            "Club Number"||'_'||TO_CHAR("Shift Start Time",'yyyy-mm-dd')||'_'||"Tender Type"||'_'||
            total_amount
        FROM
            (
                SELECT
                    "Club Number",
                    "Tender Type",
                    "Shift Start Time",
                    "Shift End Time",
                    SUM("Tender Amount") AS total_amount
                FROM
                    res
                WHERE
                    "Line Type" = '   Payment Line'
                GROUP BY
                    "Club Number",
                    "Tender Type",
                    "Shift Start Time",
                    "Shift End Time"
                HAVING
                    SUM("Tender Amount") != 0 )
    )
    ,
    tst_duplicate AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    "Sale Line ID",
                    SUM(("Sale Line ID" IS NOT NULL)::INTEGER) over (partition BY "Sale Line ID")
                    AS sl_dup
                FROM
                    res
                WHERE
                    "Line Type" = '   Detail Line')
        WHERE
            sl_dup > 1
    )
SELECT
    *
FROM
    res