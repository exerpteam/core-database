WITH 
    params AS MATERIALIZED
    (   SELECT
            id   AS center_id,
            NAME AS center_name,
            CAST(datetolongTZ(TO_CHAR(to_date(:from_date,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), 
            time_zone) AS BIGINT) AS fromDateLong,
            CAST(datetolongTZ(TO_CHAR(to_date(:to_date,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), 
            time_zone) AS BIGINT) + (24*60*60*1000) AS toDateLong
        FROM
            centers
        WHERE 
            id IN (:scope)
    )
SELECT
    pr.name                                AS "PRODUCT",
    longToDateC(crt.transtime, crt.center) AS "TRANSACTION_TIME",
    CASE
        WHEN cct.IS_CARD_ON_FILE 
        THEN 'COF_SALE'
        ELSE 'TERMINAL_SALE'
    END AS "TRANSACTION_TYPE",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN ( 
                        p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                    OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (   SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END                           AS "PERSON_ID",
    i.text                        AS "DESCRIPTION",
    --crt.amount                  AS "TOTAL_AMOUNT",
    il.total_amount               AS "AMOUNT",
    i.center ||'inv' || i.id      AS "SALE_ID",
    NULL                          AS "CREDIT_NOTE_ID",
    cct.center || 'cct' || cct.id AS "CREDIT_CARD_TRANSACTION_ID",
    cct.transaction_id            AS "TRANSACTION_ID",
    cct.ACCOUNT_NUMBER            AS "CREDIT_CARD_NUMBER",
    CASE cct."type"
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
    END                                      AS "CREDIT_CARD_TYPE",
    ccref.transaction_reference->>'authCode' AS "AUTH_CODE",
    ccref.transaction_reference->>'refNo'    AS "REF_NO",
    ccref.transaction_reference->>'recordNo' AS "DATACAP_NO"
FROM
    PARAMS
JOIN
    cashregistertransactions crt
ON
    crt.transtime >= params.fromDateLong
AND crt.transtime < params.toDateLong
AND crt.center = params.center_id
AND crt.crttype = 7
LEFT JOIN
    creditcardtransactions cct
ON
    crt.gltranscenter = cct.gl_trans_center
AND crt.gltransid = cct.gl_trans_id
AND crt.gltranssubid = cct.gl_trans_subid
LEFT JOIN
    PERSONS p
ON
    crt.customercenter = p.center
AND crt.customerid = p.id
LEFT JOIN
    invoices i
ON
    crt.paysessionid = i.paysessionid
JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id
JOIN
    PRODUCTS pr
ON
    il.productcenter = pr.center
AND il.productid = pr.id
LEFT JOIN
    CREDIT_CARD_TRANSACTION_REFERENCE ccref
ON
    ccref.transaction_reference->>'authCode' = cct.authorisation_code 
AND ccref.transaction_reference->>'refNo' = cct.transaction_id
where 
   crt.crttype = 7

UNION ALL

SELECT 
    DISTINCT 
    pr.name,
    longToDateC(crt.transtime, crt.center) AS "TRANSACTION_TIME",
    'REFUND'                                        AS "TRANSACTION_TYPE",
    CASE
        WHEN P.SEX != 'C'
        THEN
            CASE
                WHEN ( 
                        p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                    OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
                THEN
                    (   SELECT
                            EXTERNAL_ID
                        FROM
                            PERSONS
                        WHERE
                            CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                        AND ID = p.TRANSFERS_CURRENT_PRS_ID)
                ELSE p.EXTERNAL_ID
            END
        ELSE NULL
    END                                        AS "PERSON_ID",
    cn.text                                    AS "DESCRIPTION",
    ---ROUND(crt.amount,2)                       AS "TOTAL_AMOUNT",
    -ROUND(cl.total_amount,2)                  AS "AMOUNT",
    COALESCE(cn.invoice_center ||'inv' || cn.invoice_id, cl.invoiceline_center ||'inv' || cl.invoiceline_center || 'ln' || cl.invoiceline_subid)  AS "SALE_ID",
    cn.center||'cred' || cn.id                 AS "CREDIT_NOTE_ID",
    NULL                                       AS "CREDIT_CARD_TRANSACTION_ID",
    NULL                                       AS "TRANSACTION_ID",
    NULL                                       AS "CREDIT_CARD_NUMBER",
    NULL                                       AS "CREDIT_CARD_TYPE",
    NULL                                       AS "AUTH_CODE",
    NULL                                       AS "REF_NO",
    NULL                                       AS "DATACAP_NO"
FROM
    PARAMS
JOIN
    cashregistertransactions crt
ON
    crt.transtime >= params.fromDateLong
AND crt.transtime < params.toDateLong
AND crt.center = params.center_id
AND crt.crttype = 18
LEFT JOIN
    credit_notes cn
ON
    crt.paysessionid = cn.paysessionid
JOIN
    credit_note_lines_mt cl
ON
    cn.center = cl.center
AND cn.id = cl.id
LEFT JOIN
    PERSONS p
ON
    cn.payer_center = p.center
AND cn.payer_id = p.id
JOIN
    PRODUCTS pr
ON
    cl.productcenter = pr.center
AND cl.productid = pr.id

UNION ALL

SELECT
    prd.name,
    longtodatec(i.trans_time, i.center) AS "TRANSACTION_TIME",
    'PAYMENT_REQUEST'                   AS "TRANSACTION_TYPE",
    p.external_id                       AS "PERSON_ID",
    i.text                              AS "DESCRIPTION",
    --req_amount                          AS "TOTAL_AMOUNT",
    il.total_amount                     AS "AMOUNT",
    i.center ||'inv' || i.id            AS "SALE_ID",
    NULL                                AS "CREDIT_NOTE_ID",
    NULL                                AS "CREDIT_CARD_TRANSACTION_ID",
    NULL                                AS "TRANSACTION_ID",
    NULL                                AS "CREDIT_CARD_NUMBER",
    NULL                                AS "CREDIT_CARD_TYPE",
    NULL                                AS "AUTH_CODE",
    NULL                                AS "REF_NO",
    NULL                                AS "DATACAP_NO"
FROM
    payment_requests pr
JOIN
    payment_request_specifications prs
ON
    pr.inv_coll_center = prs.center
AND pr.inv_coll_id = prs.id
AND pr.inv_coll_subid = prs.subid
JOIN
    ar_trans art
ON
    art.payreq_spec_center = prs.center
AND art.payreq_spec_id = prs.id
AND art.payreq_spec_subid = prs.subid
JOIN
    invoices i
ON
    art.ref_center = i.center
AND art.ref_id = i.id
AND art.ref_type = 'INVOICE'
JOIN
    clearinghouses ch
ON
    ch.id = pr.clearinghouse_id
JOIN
    persons p
ON
    i.payer_center = p.center
AND i.payer_id = p.id
JOIN 
    params
ON  
    art.trans_time > params.fromDateLong    
    AND art.trans_time <= params.toDateLong
    AND art.center = params.center_id
JOIN
    invoice_lines_mt il
ON
    i.center = il.center
AND i.id = il.id
JOIN
    products prd
ON
    il.productcenter = prd.center
AND il.productid = prd.id
WHERE
    ch.ctype = 194
