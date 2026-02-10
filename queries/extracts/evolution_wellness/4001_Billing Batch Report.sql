-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            --            CURRENT_DATE-interval '1 day' AS from_date ,
            --            CURRENT_DATE                  AS to_date
            c.id                                           AS center,
            datetolongc($$from_date$$::DATE::VARCHAR,c.id)               AS from_date_long ,
            datetolongc($$to_date$$::DATE::VARCHAR,c.id)+1000*60*60*24-1 AS to_date_long,
            $$from_date$$::DATE                                          AS from_date,
            $$to_date$$::DATE                                            AS to_date
        FROM
            evolutionwellness.centers c
        WHERE
            c.id IN ($$scope$$)
    )
    ,
    res AS
    (
        SELECT
            longToDateC(pr.entry_time,pr.center)   AS "Billing Action Date",
            pr.req_delivery                        AS "Batch ID",
            pr.center||'pr'||pr.id||'id'||pr.subid AS "Bank Run ID",
            CASE pr.REQUEST_TYPE
                WHEN 1
                THEN 'Billing'
                WHEN 2
                THEN 'Debt Collection'
                WHEN 3
                THEN 'Reversal'
                WHEN 4
                THEN 'Reminder'
                WHEN 5
                THEN 'Refund'
                WHEN 6
                THEN 'Rebilling'
                WHEN 7
                THEN 'Legacy'
                WHEN 8
                THEN 'Zero'
                WHEN 9
                THEN 'Service Charge'
                ELSE 'Undefined'
            END                 AS "Bank Run Type",
            cp.external_id      AS "Membership No.",
            p.center||'p'||p.id AS "PersonID",
            p.fullname          AS "Account Name",
            c.name              AS "Member Home Club",
            pr.req_amount       AS "Requested Amount",
            CASE
                WHEN pr.state IN(4,18)
                THEN 0
                ELSE pr.xfr_amount
            END AS "Collected Amount",
            CASE
                    -- note: these codes are retrieved from ClearingHousePluginType.java in the
                    -- Exerp
                    -- codebase -- 2023-10-30
                WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
                THEN 'Credit Card'
                WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157,
                                  158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189,
                                  191,192)
                THEN 'Direct Debit'
                WHEN ch.ctype IN (8,16,32,128,129,131,132,133,134,135,136,139,142,147,149,151,154,
                                  161,166,
                                  170,171,174,195)
                THEN 'INVOICE'
                WHEN ch.ctype IN (201)
                THEN 'SCB'
                ELSE 'UNKNOWN'
            END     AS "Primary payment method",
            ch.name AS "Issuing/Merchant Bank",
            CASE pag.credit_card_type
                WHEN 1
                THEN 'VISA'
                WHEN 2
                THEN 'MasterCard'
                WHEN 3
                THEN 'Maestro'
                WHEN 4
                THEN 'Dankort'
                WHEN 5
                THEN 'AmericanExpress'
                WHEN 6
                THEN 'DinersClub'
                WHEN 7
                THEN 'JcB'
                WHEN 8
                THEN 'Sparbanken'
                WHEN 9
                THEN 'Shell'
                WHEN 10
                THEN 'NorskHydroUnoX'
                WHEN 11
                THEN 'OKQ8'
                WHEN 12
                THEN 'Preem'
                WHEN 13
                THEN 'Statoil'
                WHEN 14
                THEN 'StatoilRoutex'
                WHEN 15
                THEN 'Volvo'
                WHEN 16
                THEN 'VISAElectron'
                WHEN 17
                THEN 'Visa Credit'
                WHEN 18
                THEN 'BT Test Host'
                WHEN 19
                THEN 'Time'
                WHEN 20
                THEN 'Solo'
                WHEN 21
                THEN 'Laser'
                WHEN 22
                THEN 'LTF'
                WHEN 23
                THEN 'CAF'
                WHEN 24
                THEN 'Creation'
                WHEN 25
                THEN 'Clydesdale'
                WHEN 26
                THEN 'BHS Gold'
                WHEN 27
                THEN 'Mothercare Card'
                WHEN 28
                THEN 'Burton Menswear'
                WHEN 29
                THEN 'BA AirPlus'
                WHEN 30
                THEN 'EDC/Maestro'
                WHEN 31
                THEN 'Visa Debit'
                WHEN 32
                THEN 'Postcard'
                WHEN 33
                THEN 'Jelmoli Bonus Card'
                WHEN 34
                THEN 'EC/Bankomat'
                WHEN 35
                THEN 'V PAY'
                WHEN 36
                THEN 'Beeptify'
                WHEN 37
                THEN 'External device'
                WHEN 38
                THEN 'Interac'
                WHEN 39
                THEN 'Discover'
                WHEN 40
                THEN 'UnionPay'
                WHEN 41
                THEN 'AllStar'
                WHEN 42
                THEN 'Arcadia Group Card'
                WHEN 43
                THEN 'FCUK card'
                WHEN 44
                THEN 'MasterCard Debit'
                WHEN 45
                THEN 'IKEA Home card'
                WHEN 46
                THEN 'HFC Store card'
                WHEN 47
                THEN 'Accel'
                WHEN 48
                THEN 'AFFN'
                WHEN 49
                THEN 'Alipay'
                WHEN 50
                THEN 'BCMC'
                WHEN 51
                THEN 'CarnetDebit'
                WHEN 52
                THEN 'CarteBancaire'
                WHEN 53
                THEN 'Cabal'
                WHEN 54
                THEN 'Codensa'
                WHEN 55
                THEN 'CU24'
                WHEN 56
                THEN 'eftpos_australia'
                WHEN 57
                THEN 'elocredit'
                WHEN 58
                THEN 'Interlink'
                WHEN 59
                THEN 'Narania'
                WHEN 60
                THEN 'NYCE'
                WHEN 61
                THEN 'Pulse'
                WHEN 62
                THEN 'shazam_pinless'
                WHEN 63
                THEN 'Star'
                WHEN 64
                THEN 'Vias'
                WHEN 65
                THEN 'Warehouse'
                WHEN 66
                THEN 'mccredit'
                WHEN 67
                THEN 'mcstandardcredit'
                WHEN 68
                THEN 'mcstandarddebit'
                WHEN 69
                THEN 'mcpremiumcredit'
                WHEN 70
                THEN 'mcpremiumdebit'
                WHEN 71
                THEN 'mcsuperpremiumcredit'
                WHEN 72
                THEN 'mcsuperpremiumdebit'
                WHEN 73
                THEN 'mccommercialcredit'
                WHEN 74
                THEN 'mccommercialdebit'
                WHEN 75
                THEN 'mccommercialpremiumcredit'
                WHEN 76
                THEN 'mccommercialpremiumdebit'
                WHEN 77
                THEN 'mccorporatecredit'
                WHEN 78
                THEN 'mccorporatedebit'
                WHEN 79
                THEN 'mcpurchasingcredit'
                WHEN 80
                THEN 'mcpurchasingdebit'
                WHEN 81
                THEN 'mcfleetcredit'
                WHEN 82
                THEN 'mcfleetdebit'
                WHEN 83
                THEN 'mcpro'
                WHEN 84
                THEN 'mc_applepay'
                WHEN 85
                THEN 'mc_androidpay'
                WHEN 86
                THEN 'bijcard'
                WHEN 87
                THEN 'visastandardcredit'
                WHEN 88
                THEN 'visastandarddebit'
                WHEN 89
                THEN 'visapremiumcredit'
                WHEN 90
                THEN 'visapremiumdebit'
                WHEN 91
                THEN 'visasuperpremiumcredit'
                WHEN 92
                THEN 'visasuperpremiumdebit'
                WHEN 93
                THEN 'visacommercialcredit'
                WHEN 94
                THEN 'visacommercialdebit'
                WHEN 95
                THEN 'visacommercialpremiumcredit'
                WHEN 96
                THEN 'visacommercialpremiumdebit'
                WHEN 97
                THEN 'visacommercialsuperpremiumcredit'
                WHEN 98
                THEN 'visacommercialsuperpremiumdebit'
                WHEN 99
                THEN 'visacorporatecredit'
                WHEN 100
                THEN 'visacorporatedebit'
                WHEN 101
                THEN 'visapurchasingcredit'
                WHEN 102
                THEN 'visapurchasingdebit'
                WHEN 103
                THEN 'visafleetcredit'
                WHEN 104
                THEN 'visafleetdebit'
                WHEN 105
                THEN 'visadankort'
                WHEN 106
                THEN 'visapropreitary'
                WHEN 107
                THEN 'visa_applepay'
                WHEN 108
                THEN 'visa_androidpay'
                WHEN 109
                THEN 'amex_applepay'
                WHEN 110
                THEN 'boletobancario_santander'
                WHEN 111
                THEN 'diners_applepay'
                WHEN 112
                THEN 'directEbanking'
                WHEN 113
                THEN 'discover_applepay'
                WHEN 114
                THEN 'dotpay'
                WHEN 115
                THEN 'idealbn'
                WHEN 116
                THEN 'idealing'
                WHEN 117
                THEN 'idealrabobank'
                WHEN 118
                THEN 'paypal'
                WHEN 119
                THEN 'sepadirectdebit_authcap'
                WHEN 120
                THEN 'depadirectdebit_received'
                WHEN 121
                THEN 'cupcredit'
                WHEN 122
                THEN 'cupdebit'
                WHEN 123
                THEN 'Card on file'
                WHEN 124
                THEN 'MADA'
                WHEN 125
                THEN 'APPLEPAY'
                WHEN 126
                THEN 'PAYWITHGOOGLE'
                WHEN 127
                THEN 'TWINT'
                WHEN 128
                THEN 'ach'
                WHEN 129
                THEN 'paybybank'
                WHEN 1000
                THEN 'Other'
            END AS "Card type",
            CASE
                WHEN ch.ctype IN (201)
                THEN pag.bank_regno||'-'||pag.bank_branch_no||'-'||pag.bank_accno||'-'||
                    pag.bank_account_holder
                ELSE pag.bank_accno
            END AS "Card Bin & Summary",
            -- which are prepaid? I can check card type, but not all are showing a card type
            CASE
                WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
                THEN
                    CASE
                        WHEN pag.credit_card_type IN (31,44,68,70,72,76,78,80,82,88,90,92,94,96,98,
                                                      100,102,
                                                      104,119,120,122)
                        THEN 'Debit'
                        ELSE 'Credit'
                    END
                ELSE NULL
            END AS "Funding Source",
            CASE
                WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
                THEN longToDateC(pr.entry_time,pr.center)::DATE
                WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157,
                                  158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189,
                                  191,192,
                                  201)
                THEN co.sent_date
            END                          AS "Submission Date",
            pr.clearinghouse_payment_ref AS "PSP Reference",
            prs.ref                      AS "Payment Request Ref",
            CASE pr.STATE
                WHEN 3
                THEN 'Authorized'
                WHEN 2
                THEN 'Sent'
                ELSE 'Refused'
            END AS "Response Status",
            CASE
                WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
                THEN longToDateC(pr.entry_time,pr.center)
                WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157,
                                  158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189,
                                  191,192,
                                  201)
                THEN ci.received_date
            END AS "Response Received Date and Time",
            CASE
                WHEN pr.state = 12
                THEN 'Could not be sent'
                ELSE pr.xfr_info
            END AS "Rejection Reason",
            CASE
                WHEN pr.state = 12
                THEN 'Could not be sent'
                ELSE pr.xfr_info
            END AS "Raw Acquirer Reason",
            CASE
                WHEN pr.xfr_info IN ('901 - Invalid Merchant Account',
                                     'Unknown',
                                     'Refused',
                                     'Referral',
                                     'Acquirer Error',
                                     'Expired Card',
                                     'Invalid Amount',
                                     'Insufficient Funds',
                                     'Issuer Unavailable',
                                     'Not supported',
                                     '3D Not Authenticated',
                                     'Not enough balance',
                                     'Cancelled',
                                     'Shopper Cancelled',
                                     'Invalid Pin',
                                     'Pin tries exceeded',
                                     'Pin validation not possible',
                                     'Not Submitted',
                                     'Transaction Not Permitted',
                                     'CVC Declined',
                                     'Declined Non Generic',
                                     'Withdrawal amount exceeded',
                                     'Withdrawal count exceeded',
                                     'AVS Declined',
                                     'Card requires online pin',
                                     'Authentication required',
                                     '10',
                                     '20',
                                     '21',
                                     '31',
                                     '40',
                                     '42',
                                     '43',
                                     '44',
                                     '45',
                                     '46',
                                     '47',
                                     '50',
                                     '51',
                                     '61',
                                     '70',
                                     '71',
                                     '72',
                                     '73',
                                     '74',
                                     '75',
                                     '76',
                                     '90',
                                     '99',
                                     '1010',
                                     '1042',
                                     '1051',
                                     '1070',
                                     '1074',
                                     '1100',
                                     '1101',
                                     '1102',
                                     '1106',
                                     '1107',
                                     '1114',
                                     '1161',
                                     '1162',
                                     '1163',
                                     '1164',
                                     '1165',
                                     '1166',
                                     '1168',
                                     '1169',
                                     '1170',
                                     '1171',
                                     '1172',
                                     '1181',
                                     '1200',
                                     '1202',
                                     '1203',
                                     '1205',
                                     '1206',
                                     '1207',
                                     '1208',
                                     '1209',
                                     '1211',
                                     '1212',
                                     '1213',
                                     '1214',
                                     '1215',
                                     '1216',
                                     '1217',
                                     '1218',
                                     '1219',
                                     '1237',
                                     '1238',
                                     '1239',
                                     '1242',
                                     '1243',
                                     '1245',
                                     '1248',
                                     '1251',
                                     '1252',
                                     '1253',
                                     '1255',
                                     '1257',
                                     '1258',
                                     '1259',
                                     '1260',
                                     '1262',
                                     '1267',
                                     '1909',
                                     '1930',
                                     '9800',
                                     '9801',
                                     '9803',
                                     '9807',
                                     '9811',
                                     '9812',
                                     '9813',
                                     '9814',
                                     '9828',
                                     '9844',
                                     '9875',
                                     '9876',
                                     '9877',
                                     '9888',
                                     '9899',
                                     '9902',
                                     '9903',
                                     '9904',
                                     '9905',
                                     '9906',
                                     '9909',
                                     '9913',
                                     '9946',
                                     '9947',
                                     '9950',
                                     '9951',
                                     '9964',
                                     '9965',
                                     '9966',
                                     '9967',
                                     'Acquirer Error',
                                     'Not enough balance',
                                     'Refused',
                                     '901 - Invalid Merchant Account',
                                     'Saldo tidak cukup',
                                     'SALDO TIDAK CUKUP',
                                     'Refused',
                                     'Declined Non Generic',
                                     'Not enough balance',
                                     'Withdrawal count exceeded',
                                     'Withdrawal amount exceeded',
                                     'Insufficient Funds',
                                     'Uncollected Funds',
                                     'Unknown',
                                     'Referral',
                                     'Acquirer Error',
                                     'Expired Card',
                                     'Invalid Amount',
                                     'Issuer Unavailable',
                                     'Invalid Pin',
                                     'Pin tries exceeded',
                                     'Not Submitted',
                                     'READABLE',
                                     '000 - Read timed out')
                OR  pr.rejected_reason_code = 'Customer Buyer Arrangement Not Maintained'
                THEN 2
                WHEN pr.rejected_reason_code IS NULL
                THEN NULL
                ELSE 1
            END              AS "Rejection Category",
            staff.nickname   AS "Employee Name",
            payroll.txtvalue AS "Employee ID",
            pr.req_date      AS "Deduction Date"
        FROM
            params
        JOIN
            payment_requests pr
        ON
            pr.center = params.center
        JOIN
            account_receivables ar
        ON
            ar.center =pr.center
        AND ar.id = pr.id
        JOIN
            persons p
        ON
            p.center = ar.customercenter
        AND p.id = ar.customerid
        JOIN
            evolutionwellness.persons cp
        ON
            cp.center = p.transfers_current_prs_center
        AND cp.id = p.transfers_current_prs_id
        JOIN
            centers c
        ON
            c.id = p.center
        JOIN
            clearinghouses ch
        ON
            ch.id = pr.clearinghouse_id
        JOIN
            payment_request_specifications prs
        ON
            pr.inv_coll_center = prs.center
        AND pr.inv_coll_id = prs.id
        AND pr.inv_coll_subid = prs.subid
        LEFT JOIN
            payment_agreements pag
        ON
            pr.agr_subid = pag.subid
        AND pr.center = pag.center
        AND pag.id = pr.id
        LEFT JOIN
            clearing_in ci
        ON
            pr.xfr_delivery = ci.id
        LEFT JOIN
            clearing_out co
        ON
            pr.req_delivery = co.id
        LEFT JOIN
            evolutionwellness.employees emp
        ON
            emp.center = pr.employee_center
        AND emp.id = pr.employee_id
        LEFT JOIN
            evolutionwellness.persons staff
        ON
            staff.center = emp.personcenter
        AND staff.id = emp.personid
        LEFT JOIN
            evolutionwellness.person_ext_attrs payroll
        ON
            payroll.personcenter = staff.center
        AND payroll.personid = staff.id
        AND payroll.name = '_eClub_StaffExternalId'
        WHERE
            pr.entry_time BETWEEN params.from_date_long AND params.to_date_long
        AND pr.state != 8
        AND pr.req_amount != 0
        AND (
                pr.req_delivery IS NOT NULL
            OR  ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194) -- cc
            )
    )
    ,
    tst_reconcile AS
    (
        SELECT
            COUNT(*),
            COUNT(DISTINCT "Bank Run ID"),
            SUM("Requested Amount"),
            SUM("Collected Amount")
        FROM
            res
    )
    ,
    tst_duplicates AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    *,
                    COUNT(*) over (partition BY "Bank Run ID") AS pr_dup -- each pr should only
                    -- appear once
                FROM
                    res)
        WHERE
            pr_dup > 1
    )
SELECT
    *
FROM
    res
    /*WHERE
    "Bank Run ID" = '117pr1936id4'*/
    