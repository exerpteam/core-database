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
    params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                      AS center,
            datetolongc($$from_date$$::DATE::VARCHAR,c.id)                 AS from_date_long ,
            datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long,
            $$from_date$$::DATE                                            AS from_date,
            $$to_date$$::DATE                                            AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
    ,
    shifts AS
    (
        SELECT
            *
        FROM
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
                        THEN longtodatec(lead(log_time) over (partition BY crl.cash_register_center
                            , crl.cash_register_id ORDER BY log_time DESC),crl.cash_register_center
                            )
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
                    END AS register_open_long,
                    params.from_date_long,
                    params.to_date_long
                FROM
                    params
                JOIN
                    evolutionwellness.cash_register_log crl
                ON
                    crl.cash_register_center = params.center
                WHERE
                    log_type IN('CLOSE_CASH_REGISTER',
                                'OPEN_CASH_REGISTER')) r1
        WHERE
            register_close_long BETWEEN r1.from_date_long AND r1.to_date_long
    )
    ,
    res AS
    (
        SELECT
            c.name                                           AS "Club" ,
            c.id                                             AS "Club Number" ,
            c.external_id                                    AS "Club Code" ,
            t.cash_register_center||'cr'||t.cash_register_id AS "Workstation" ,
            TO_CHAR(t.register_open,'YYYY-MM-DD')            AS "Shift Start Date" ,
            TO_CHAR(t.register_open, 'HH24:MI:SS')           AS "Shift Start Time" ,
            TO_CHAR(t.register_close,'YYYY-MM-DD')           AS "Shift End Date" ,
            TO_CHAR(t.register_close, 'HH24:MI:SS')          AS "Shift End Time" ,
            t.lenght                                         AS "Shift Length (Hours)" ,
            p.fullname                                       AS "Operator" ,
            NULL "Accounting Reference" ,
            t."Tender Type" ,
            t."Tender" ,
            NULL                   AS "Reference" ,
            t.Expected             AS "Expected Amount" ,
            t.Actuals              AS "Actual Amount" ,
            t.Actuals - t.Expected AS "Discrepancy"
        FROM
            (
                SELECT
                    shifts.cash_register_center,
                    shifts.cash_register_id,
                    shifts.register_open,
                    shifts.register_close,
                    shifts.register_close_long,
                    shifts.register_open_long,
                    register_close-register_open AS lenght,
                    'CASH'                       AS "Tender Type",
                    'CASH'                       AS "Tender",
                    SUM(
                        CASE
                            WHEN crt.crttype IN (10,11,16)
                            THEN crt.amount
                            ELSE 0
                        END) AS Actuals,
                    SUM(
                        CASE
                            WHEN crt.crttype = 1
                            THEN crt.amount
                            ELSE 0
                        END) - SUM(
                        CASE
                            WHEN crt.crttype IN (4,2)
                            THEN crt.amount
                            ELSE 0
                        END) AS Expected
                FROM
                    shifts
                JOIN
                    evolutionwellness.cashregistertransactions crt
                ON
                    crt.crcenter = shifts.cash_register_center
                AND crt.crid = shifts.cash_register_id
                AND crt.transtime > shifts.register_open_long
                AND (
                        crt.transtime < shifts.register_close_long
                    OR  shifts.register_close_long IS NULL)
                GROUP BY
                    shifts.cash_register_center,
                    shifts.cash_register_id,
                    shifts.register_open,
                    shifts.register_close,
                    shifts.register_close_long,
                    shifts.register_open_long
                UNION ALL
                SELECT
                    t.cash_register_center,
                    t.cash_register_id,
                    t.register_open,
                    t.register_close,
                    t.register_close_long,
                    t.register_open_long,
                    t.register_close-register_open AS lenght,
                    t."Tender Type",
                    t."Tender",
                    SUM(t.Actuals)  AS Actuals,
                    SUM(t.expected) AS Expected
                FROM
                    (
                        SELECT
                            shifts.cash_register_center,
                            shifts.cash_register_id,
                            shifts.register_open,
                            shifts.register_close,
                            shifts.register_close_long,
                            shifts.register_open_long,
                            register_close-register_open,
                            CASE
                                WHEN crt.CRTTYPE = 5
                                THEN 'PAID BY CASH AR ACCOUNT'
                                WHEN crt.CRTTYPE = 12
                                THEN 'PAYMENT AR'
                                WHEN crt.CRTTYPE = 13
                                THEN 'OTHER'
                                WHEN crt.CRTTYPE = 17
                                THEN 'VOUCHER'
                                WHEN crt.CRTTYPE = 18
                                THEN 'PAYOUT CREDIT CARD'
                                WHEN crt.CRTTYPE = 19
                                THEN 'TRANSFER BETWEEN REGISTERS'
                                WHEN crt.CRTTYPE = 21
                                THEN 'TRANSFER BACK CASH COINS'
                                ELSE NULL
                            END AS "Tender Type",
                            COALESCE(icpm.name,
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
                            END)       AS "Tender",
                            crt.amount AS Actuals,
                            crt.amount AS expected
                        FROM
                            shifts
                        JOIN
                            evolutionwellness.cashregistertransactions crt
                        ON
                            crt.crcenter = shifts.cash_register_center
                        AND crt.crid = shifts.cash_register_id
                        AND crt.transtime BETWEEN shifts.register_open_long AND
                            shifts.register_close_long
                        AND crt.crttype IN (5,12,13,17,18)
                        JOIN
                            evolutionwellness.centers c
                        ON
                            c.id = crt.crcenter
                        LEFT JOIN
                            center_config_payment_method_id icpm
                        ON
                            crt.center =icpm.center_id
                        AND crt.config_payment_method_id = icpm.id
                        AND crt.crttype NOT IN (10,11,15,16,20) )t
                GROUP BY
                    t.cash_register_center,
                    t.cash_register_id,
                    t.register_open,
                    t.register_close,
                    t.register_close_long,
                    t.register_open_long,
                    t."Tender Type",
                    t."Tender" 
                UNION ALL
                SELECT
                    shifts.cash_register_center,
                    shifts.cash_register_id,
                    shifts.register_open,
                    shifts.register_close,
                    shifts.register_close_long,
                    shifts.register_open_long,
                    register_close-register_open AS lenght,
                    'CREDIT NOTE'                       AS "Tender Type",
                    'CREDIT NOTE'                       AS "Tender",--longtodatec(cn.trans_time,cn.center),cn.*
                    SUM(cnl.total_amount)AS Actuals,
                    SUM(cnl.total_amount)AS Expected
                FROM
                    shifts
                JOIN
                    evolutionwellness.credit_notes cn
                    ON cn.cashregister_center = shifts.cash_register_center
                JOIN 
                    params
                    ON params.center = cn.cashregister_center
                JOIN
                    evolutionwellness.credit_note_lines_mt cnl
                    ON cnl.center = cn.center AND cnl.id = cn.id
                WHERE
                    longtodatec(cn.entry_time,cn.center) BETWEEN shifts.register_open AND shifts.register_close
                    AND
                    cnl.total_amount != 0

                GROUP BY
                    shifts.cash_register_center,
                    shifts.cash_register_id,
                    shifts.register_open,
                    shifts.register_close,
                    shifts.register_close_long,
                    shifts.register_open_long,
                    register_close-register_open
                    )t
        LEFT JOIN
            cash_register_log crl
        ON
            t.cash_register_center = crl.cash_register_center
        AND t.cash_register_id = crl.cash_register_id
        AND t.register_close_long = crl.log_time
        AND crl.log_type = 'CLOSE_CASH_REGISTER'
        LEFT JOIN
            evolutionwellness.centers c
        ON
            c.id = t.cash_register_center
        LEFT JOIN
            evolutionwellness.employees emp
        ON
            emp.center = crl.employee_center
        AND emp.id = crl.employee_id
        LEFT JOIN
            evolutionwellness.persons p
        ON
            p.center = emp.personcenter
        AND p.id = emp.personid
    )
    ,
    tst_reconcile AS
    (
        SELECT
            "Club Number"||'_'||"Shift Start Date"||'_'||"Tender"||'_'||total_amount,
            *
        FROM
            (
                SELECT
                    "Club Number",
                    "Tender",
                    "Shift Start Date",
                    SUM("Expected Amount") AS total_amount
                FROM
                    res W
                GROUP BY
                    "Club Number",
                    "Tender",
                    "Shift Start Date"
                HAVING
                    SUM("Expected Amount") != 0)
    )
SELECT
    *
FROM
    res