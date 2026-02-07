SELECT DISTINCT
p.external_id,
p.center||'p'||p.id AS PersonID,
p.center,		
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
    END AS "Card type"
FROM
    payment_requests pr
JOIN
    account_receivables ar
ON
    ar.center =pr.center
AND ar.id = pr.id
JOIN
    payment_agreements pag
ON
    pr.agr_subid = pag.subid
AND pr.center = pag.center
AND pag.id = pr.id
JOIN
persons p
ON p.center = ar.customercenter
AND p.id = ar.customerid
WHERE
pr.center in (:Scope)
AND pr.clearinghouse_id = 2
AND p.sex != 'C'
AND pag.state = 4