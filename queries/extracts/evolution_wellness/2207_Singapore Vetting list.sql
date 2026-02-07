WITH
    params AS MATERIALIZED
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
            c.id                                                                 AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI')
            ,c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    )
    ,
    sell_on_behalf AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    il.center,
                    il.id,
                    il.subid,
                    ise.sales_employee_center AS employee_center,
                    ise.sales_employee_id     AS employee_id,
                    row_number() over (partition BY il.center,il.id,il.subid ORDER BY
                    ise.start_time DESC) AS rnk
                FROM
                    params,
                    invoice_sales_employee ise
                JOIN
                    evolutionwellness.invoice_lines_mt il
                ON
                    il.center = ise.invoice_center
                AND il.id = ise.invoice_id ) t
        WHERE
            rnk = 1
    )
SELECT DISTINCT
    c.name         AS "Club" ,
    c.id           AS "Club Number" ,
    c. external_id AS "Club Code" ,
    corp.fullname  AS "Corporate Name" ,
    p.external_id  AS "Member Number" ,
    p.fullname     AS "Member Name" ,
    ss.sales_date  AS "Join Date" ,
    CASE s.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Membership Status" ,
    CASE
        WHEN ccc.id IS NULL
        THEN 'OK'
        ELSE 'Arrears'
    END               AS "Payment Status" ,
    employee.fullname AS "Sales Person" ,
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
        ELSE 'Undefined'
    END                                                  AS "Change Type" ,
    longtodatec(s.creation_time,s.center)                AS "Change Date" ,
    CURRENT_DATE - longtodatec(s.creation_time,s.center) AS "Days Since Change" ,
    NULL                                                 AS "Package Name" ,
    prod.name                                            AS "Plan Name" ,
    CASE
            -- note: these codes are retrieved from ClearingHousePluginType.java in the Exerp
            -- codebase -- 2023-10-30
        WHEN ch.ctype IN (141,144,160,169,173,175,183,184,186,188,190,193,194)
        THEN 'Credit Card'
        WHEN ch.ctype IN (1,2,4,64,130,137,140,143,145,146,148,150,152,153,155,156,157,
                          158,159,165,167,168,172,176,177,178,179,180,181,182,185,187,189,191,192)
        THEN 'Direct Debit'
        WHEN ch.ctype IN (8,16,32,128,129,131,132,133,134,135,136,139,142,147,149,151,154,161,166,
                          170,171,174,195)
        THEN 'INVOICE'
        ELSE 'UNKNOWN'
    END AS "Payment Method" ,
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
    END                  AS "Card type",
    NULL                 AS "Funding Source" ,
    NULL                 AS "Plan Class" ,
    SGVetting1.txtvalue  AS "Are all the signatures field signed" ,
    SGVetting15.txtvalue AS "Has payment agreement been completed" ,
    SGVetting2.txtvalue  AS "Has supporting document provided for delayed start more than 30days" ,
    SGVeting3.txtvalue   AS
    "Is the Family add-on proof provided (FAO Nomination Form or Proof of same address or relationship)"
    ,
    SGVetting4.txtvalue AS "Is valid Corporate proof provided" ,
    SGVetting5.txtvalue AS
    "Has the DD Mandate been completed correctly (All details completed & signed/ pre-approved thumbprint)"
    ,
    SGVetting17.txtvalue AS "Has the first month monthly dues collected(DD joiner)" ,
    SGVetting6.txtvalue  AS "Is the Bank Account Number match the DD Mandate" ,
    SGVetting7.txtvalue  AS "Parental Consent form - Has the paper contract been uploaded" ,
    SGVetting8.txtvalue  AS "Additional FV Reason" ,
    SGVetting9.txtvalue  AS "Fitness Service Sold" ,
    SGVetting10.txtvalue AS "Standard PT Sold at POS" ,
    SGVetting11.txtvalue AS "WWYB joiner" ,
    SGVetting12.txtvalue AS "Comissionable" ,
    SGVetting13.txtvalue AS "Vetting Passed" ,
    SGVetting14.txtvalue AS "1st Vet Name" ,
    SGVetting18.txtvalue AS "Final Vet Name" ,
    CASE
        WHEN employee.fullname LIKE '%API%'
        THEN 'Yes'
        ELSE 'No'
    END  AS "Join Online" ,
    NULL AS "Modular Plan" ,
    CASE
        WHEN prod_addon.name LIKE '%HIIT%'
        THEN 'Yes'
        ELSE 'No'
    END AS "Add-On GX Class - HIIT" ,
    CASE
        WHEN prod_addon.name LIKE '%Mind%'
        THEN 'Yes'
        ELSE 'No'
    END AS "Add-On GX Class - Mind and Body" ,
    CASE
        WHEN prod_addon.name LIKE '%Cycl%'
        THEN 'Yes'
        ELSE 'No'
    END AS "Add-On GX Class - Cycling" ,
    CASE
        WHEN prod_addon.name LIKE '%Group%'
        THEN 'Yes'
        ELSE 'No'
    END AS "Add-On GX Class - Unlimited" ,
    CASE
        WHEN prodp.product_group_id IS NULL
        THEN 'No'
        ELSE 'Yes'
    END AS "Gym Only"
FROM
    evolutionwellness.persons p
JOIN
    evolutionwellness.centers c
ON
    c.id = p.center
LEFT JOIN
    evolutionwellness.relatives r
ON
    r.relativecenter = p.center
AND r.relativeid = p.id
AND r.status < 2
LEFT JOIN
    evolutionwellness.persons corp
ON
    corp.center = r.center
AND corp.id = r.id
JOIN
    evolutionwellness.subscriptions s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
LEFT JOIN
    evolutionwellness.subscription_sales ss
ON
    ss.subscription_center = s.center
AND ss.subscription_id = s.id
LEFT JOIN
    sell_on_behalf sob
ON
    sob.center = s.invoiceline_center
AND sob.id = s.invoiceline_id
AND sob.subid = s.invoiceline_subid
LEFT JOIN
    evolutionwellness.employees emp
ON
    emp.center = COALESCE(sob.employee_center, ss.employee_center)
AND emp.id = COALESCE(sob.employee_id, ss.employee_id)
LEFT JOIN
    evolutionwellness.persons employee
ON
    employee.center = emp.personcenter
AND employee.id = emp.personid
JOIN
    evolutionwellness.subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
JOIN
    evolutionwellness.products prod
ON
    prod.center = st.center
AND prod.id = st.id
LEFT JOIN
    evolutionwellness.product_and_product_group_link prodp
ON
    prodp.product_center = prod.center
AND prodp.product_id = prod.id
AND prodp.product_group_id = 688
LEFT JOIN
    evolutionwellness.subscription_addon sao
ON
    sao.subscription_center = s.center
AND sao.subscription_id = s.id
AND sao.cancelled != 'true'
AND (
        sao.end_date > CURRENT_DATE
    OR  sao.end_date IS NULL)
LEFT JOIN
    evolutionwellness.subscription_addon_product saop
ON
    saop.addon_product_id = sao.addon_product_id
LEFT JOIN
    evolutionwellness.MASTERPRODUCTREGISTER mpr_addon
ON
    mpr_addon.id = sao.ADDON_PRODUCT_ID
LEFT JOIN
    evolutionwellness.PRODUCTS prod_addon
ON
    prod_addon.center = sao.CENTER_ID
AND prod_addon.GLOBALID = mpr_addon.GLOBALID
JOIN
    params
ON
    params.center_id = s.center
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting13 -- Vetting Passed
ON
    SGVetting13.personcenter = p.center
AND SGVetting13.personid = p.id
AND SGVetting13.name = 'SGVetting13'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting1 -- Are all the signatures field signed
ON
    SGVetting1.personcenter = p.center
AND SGVetting1.personid = p.id
AND SGVetting1.name = 'SGVetting1'
LEFT JOIN
    evolutionwellness.person_ext_attrs Vetting15--Has payment agreement been completed
ON
    Vetting15.personcenter = p.center
AND Vetting15.personid = p.id
AND Vetting15.name = 'Vetting15'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting10--Standard PT Sold at POS
ON
    SGVetting10.personcenter = p.center
AND SGVetting10.personid = p.id
AND SGVetting10.name = 'SGVetting10'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting11--WWYB joiner
ON
    SGVetting11.personcenter = p.center
AND SGVetting11.personid = p.id
AND SGVetting11.name = 'SGVetting11'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting12--Comissionable
ON
    SGVetting12.personcenter = p.center
AND SGVetting12.personid = p.id
AND SGVetting12.name = 'SGVetting12'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting14--1st Vet Name
ON
    SGVetting14.personcenter = p.center
AND SGVetting14.personid = p.id
AND SGVetting14.name = 'SGVetting14'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting18--Final Vet Name
ON
    SGVetting18.personcenter = p.center
AND SGVetting18.personid = p.id
AND SGVetting18.name = 'SGVetting18'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting2--Has supporting document provided for delayed
    -- start more than 30days
ON
    SGVetting2.personcenter = p.center
AND SGVetting2.personid = p.id
AND SGVetting2.name = 'SGVetting2'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVeting3--Is the Family add-on proof provided (FAO
    -- Nomination Form or Proof of same address or relationship)
ON
    SGVeting3.personcenter = p.center
AND SGVeting3.personid = p.id
AND SGVeting3.name = 'SGVeting3'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting4--Is valid Corporate proof provided
ON
    SGVetting4.personcenter = p.center
AND SGVetting4.personid = p.id
AND SGVetting4.name = 'SGVetting4'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting5--Has the DD Mandate been completed correctly?
    -- (All details completed & signed/ pre-approved thumbprint)
ON
    SGVetting5.personcenter = p.center
AND SGVetting5.personid = p.id
AND SGVetting5.name = 'SGVetting5'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting6-- Is the Bank Account Number match the DD Mandate
ON
    SGVetting6.personcenter = p.center
AND SGVetting6.personid = p.id
AND SGVetting6.name = 'SGVetting6'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting7--Parental Consent form - Has the paper contract
    -- been uploaded
ON
    SGVetting7.personcenter = p.center
AND SGVetting7.personid = p.id
AND SGVetting7.name = 'SGVetting7'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting15--Has payment agreement been completed
ON
    SGVetting15.personcenter = p.center
AND SGVetting15.personid = p.id
AND SGVetting15.name = 'SGVetting15'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting9--Fitness Service Sold
ON
    SGVetting9.personcenter = p.center
AND SGVetting9.personid = p.id
AND SGVetting9.name = 'SGVetting9'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting17--DD joiners- has the first month monthly dues
    -- collected
ON
    SGVetting17.personcenter = p.center
AND SGVetting17.personid = p.id
AND SGVetting17.name = 'SGVetting17'
LEFT JOIN
    evolutionwellness.person_ext_attrs SGVetting8--Additional FV Reason
ON
    SGVetting8.personcenter = p.center
AND SGVetting8.personid = p.id
AND SGVetting8.name = 'SGVetting8'
LEFT JOIN
    evolutionwellness.cashcollectioncases ccc
ON
    ccc.personcenter = p.center
AND ccc.personid = p.id
AND NOT(
        ccc.closed)
AND ccc.missingpayment
LEFT JOIN
    evolutionwellness.account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
LEFT JOIN
    evolutionwellness.payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
LEFT JOIN
    evolutionwellness.payment_agreements pag
ON
    pag.center = ar.center
AND pag.id = ar.id
AND pag.subid = pac.active_agr_subid
LEFT JOIN
    evolutionwellness.clearinghouses ch
ON
    ch.id = pag.clearinghouse
WHERE
    p.center IN (:Scope)
AND s.creation_time BETWEEN params.FromDate AND params.ToDate