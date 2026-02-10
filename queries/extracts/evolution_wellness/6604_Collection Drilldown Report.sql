-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS
  (
        SELECT
                /*+ materialize */
                :Month AS FromMonth,
                c.id AS CENTER_ID,
                :Year AS FromYear                                             
        FROM
          centers c
  ),
  Eligible_members AS
  (
        SELECT
                CASE
                        WHEN c.country = 'SG' THEN 'Singapore'
                        WHEN c.country = 'ID' THEN 'Indonesia'
                        WHEN c.country = 'PH' THEN 'Philippines'
                        WHEN c.country = 'MY' THEN 'Malaysia'
                        WHEN c.country = 'TH' THEN 'Thailand'
                        ELSE NULL
                END AS "Country Name"
                ,c.name AS "Club Name"
                ,p.external_id AS "Membership Number"
                ,'Pay Monthly' AS "Plan Payment Type"
                ,TO_CHAR(art.due_date, 'Month')||EXTRACT(YEAR FROM art.due_date) AS "Billing Month"
                ,invl.center
                ,invl.id
                ,invl.subid
                ,p.center as personcenter
                ,p.id AS personid
                ,art.due_date
        FROM
                evolutionwellness.persons p
        JOIN
                evolutionwellness.invoices inv 
                ON inv.payer_center = p.center
                AND inv.payer_id = p.id
        JOIN
                evolutionwellness.invoice_lines_mt invl
                ON inv.center = invl.center
                AND inv.id = invl.id
                AND invl.reason = 9 
        JOIN
                evolutionwellness.ar_trans art
                ON art.ref_center = inv.center
                AND art.ref_id = inv.id                
        JOIN
                evolutionwellness.centers c
                ON c.id = p.center
        JOIN
                params
                ON params.center_id = c.id                                      
        WHERE
                EXTRACT(MONTH FROM art.due_date) = params.FromMonth
                AND
                EXTRACT(YEAR FROM art.due_date) = params.FromYear   
                AND 
                p.sex != 'C'
                AND 
                p.center IN (:Scope)
                AND
                p.external_id IS NOT NULL
   )

SELECT 
                t."Country Name"
                ,t."Club Name"
                ,t."Membership Number"
                ,t."Plan Payment Type"
                ,t."Billing Month"
                ,t."Paid Billing"
                ,t."Rebill Count"
                ,t."Charge Amount"
                ,t."Written Off"
                ,t."Outstanding"
                ,t."Invoiced"
                ,t."Refunded"
                ,SUM(t."Paid Club") AS "Paid Club"
                ,t."Paid HO"
                ,t."Rebilled Amount"
                ,SUM(t."Advanced Amount") AS "Advanced Amount" 
                ,t."Payment Method Type Code"         
                ,t."Billing Date"
                ,t."Member Status"
                ,MAX(t."Billing Payment Date") AS "Billing Payment Date"
                ,t."Action Date"
                ,t."Member Status At End Of Month"
                ,t."Primary Payment Method"
                ,t."Card Type"
                ,t."Funding Source"
                ,t."Bulk Write-Off Exclusion"
FROM
        (     
        SELECT DISTINCT 
                em."Country Name"
                ,em."Club Name"
                ,em."Membership Number"
                ,em."Plan Payment Type"
                ,em."Billing Month"
                ,CASE
                        WHEN pr.center IS NOT NULL THEN pr.xfr_amount 
                        ELSE 0
                END AS "Paid Billing"
                ,CASE
                        WHEN prr.count IS NOT NULL THEN prr.count
                        ELSE 0
                END AS "Rebill Count"
                ,-art.amount AS "Charge Amount"
                ,CASE
                        WHEN artp.ref_type = 'CREDIT_NOTE' AND cnl.reason IN (26,17,16,10,24) THEN 
                                CASE 
                                        WHEN artp.amount > -art.amount THEN -art.amount
                                        ELSE artp.amount
                                END
                        ELSE 0
                END AS "Written Off"
                ,CASE
                        WHEN art.status = 'CLOSED' THEN 0
                        ELSE -art.unsettled_amount
                END AS "Outstanding"
                ,0 AS "Invoiced"
                ,CASE
                        WHEN artp.ref_type = 'CREDIT_NOTE' AND cnl.reason IN (14,15,11) THEN artm.amount
                        ELSE 0
                END AS "Refunded"
                ,CASE
                        WHEN artp.employeecenter ||'emp'|| artp.employeeid NOT IN ('999emp2401','300emp2601','999emp207') AND artp.ref_type != 'CREDIT_NOTE' THEN artm.amount               
                        ELSE 0
                END "Paid Club"
                ,CASE
                        WHEN artp.employeecenter ||'emp'|| artp.employeeid IN ('999emp2401','300emp2601','999emp207') THEN artm.amount
                        ELSE 0
                END "Paid HO"
                ,CASE
                        WHEN prr.inv_coll_center IS NOT NULL THEN prr.req_amount
                        ELSE 0 
                END AS "Rebilled Amount"
                ,CASE
                        WHEN artp.entry_time < art.entry_time AND (cnl.reason IS NULL OR cnl.reason IN (7,3,6,8,5,4,2,12,13)) THEN artm.amount
                        ELSE 0
                END AS "Advanced Amount" 
                ,CASE
                        WHEN pr.clearinghouse_id IN (401,201,202,801,602,601,603,604,605,802,803,804,1202,1402,1201) THEN 'CC'
                        WHEN pr.clearinghouse_id IN (1401,1602,1601,1001) THEN 'DD'
                        WHEN pr.clearinghouse_id IN (1) THEN 'INV'
        END AS "Payment Method Type Code"        
                ,CASE
                        WHEN pr.clearinghouse_id IN (401,201,202,801,602,601,603,604,605,802,803,804,1201) THEN em.due_date
                        WHEN pr.clearinghouse_id IN (1401,1602,1601,1001,1202,1402) THEN pr.req_date
                        ELSE NULL
                END AS "Billing Date"
                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Member Status"
                ,CASE
                        WHEN art.status != 'CLOSED' THEN NULL
                        ELSE longtodatec(artm.entry_time,artm.art_paying_center)
                END AS "Billing Payment Date"
                ,em.due_date AS "Action Date"
                ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Member Status At End Of Month"
                ,CASE
                        WHEN pr.clearinghouse_id IN (401,201,202,801,602,601,603,604,605,802,803,804,1202,1402,1201) THEN 'Credit Card'
                        WHEN pr.clearinghouse_id IN (1401,1602,1601,1001) THEN 'Direct Debit'
                        WHEN pr.clearinghouse_id IN (1) THEN 'Invoice'
                END AS "Primary Payment Method"
                ,CASE pag.credit_card_type
                        WHEN 1 THEN 'VISA'
                        WHEN 2 THEN 'MasterCard'
                        WHEN 3 THEN 'Maestro'
                        WHEN 4 THEN 'Dankort'
                        WHEN 5 THEN 'AmericanExpress'
                        WHEN 6 THEN 'DinersClub'
                        WHEN 7 THEN 'JcB'
                        WHEN 8 THEN 'Sparbanken'
                        WHEN 9 THEN 'Shell'
                        WHEN 10 THEN 'NorskHydroUnoX'
                        WHEN 11 THEN 'OKQ8'
                        WHEN 12 THEN 'Preem'
                        WHEN 13 THEN 'Statoil'
                        WHEN 14 THEN 'StatoilRoutex'
                        WHEN 15 THEN 'Volvo'
                        WHEN 16 THEN 'VISAElectron'
                        WHEN 17 THEN 'Visa Credit'
                        WHEN 18 THEN 'BT Test Host'
                        WHEN 19 THEN 'Time'
                        WHEN 20 THEN 'Solo'
                        WHEN 21 THEN 'Laser'
                        WHEN 22 THEN 'LTF'
                        WHEN 23 THEN 'CAF'
                        WHEN 24 THEN 'Creation'
                        WHEN 25 THEN 'Clydesdale'
                        WHEN 26 THEN 'BHS Gold'
                        WHEN 27 THEN 'Mothercare Card'
                        WHEN 28 THEN 'Burton Menswear'
                        WHEN 29 THEN 'BA AirPlus'
                        WHEN 30 THEN 'EDC/Maestro'
                        WHEN 31 THEN 'Visa Debit'
                        WHEN 32 THEN 'Postcard'
                        WHEN 33 THEN 'Jelmoli Bonus Card'
                        WHEN 34 THEN 'EC/Bankomat'
                        WHEN 35 THEN 'V PAY'
                        WHEN 36 THEN 'Beeptify'
                        WHEN 37 THEN 'External device'
                        WHEN 38 THEN 'Interac'
                        WHEN 39 THEN 'Discover'
                        WHEN 40 THEN 'UnionPay'
                        WHEN 41 THEN 'AllStar'
                        WHEN 42 THEN 'Arcadia Group Card'
                        WHEN 43 THEN 'FCUK card'
                        WHEN 44 THEN 'MasterCard Debit'
                        WHEN 45 THEN 'IKEA Home card'
                        WHEN 46 THEN 'HFC Store card'
                        WHEN 47 THEN 'Accel'
                        WHEN 48 THEN 'AFFN'
                        WHEN 49 THEN 'Alipay'
                        WHEN 50 THEN 'BCMC'
                        WHEN 51 THEN 'CarnetDebit'
                        WHEN 52 THEN 'CarteBancaire'
                        WHEN 53 THEN 'Cabal'
                        WHEN 54 THEN 'Codensa'
                        WHEN 55 THEN 'CU24'
                        WHEN 56 THEN 'eftpos_australia'
                        WHEN 57 THEN 'elocredit'
                        WHEN 58 THEN 'Interlink'
                        WHEN 59 THEN 'Narania'
                        WHEN 60 THEN 'NYCE'
                        WHEN 61 THEN 'Pulse'
                        WHEN 62 THEN 'shazam_pinless'
                        WHEN 63 THEN 'Star'
                        WHEN 64 THEN 'Vias'
                        WHEN 65 THEN 'Warehouse'
                        WHEN 66 THEN 'mccredit'
                        WHEN 67 THEN 'mcstandardcredit'
                        WHEN 68 THEN 'mcstandarddebit'
                        WHEN 69 THEN 'mcpremiumcredit'
                        WHEN 70 THEN 'mcpremiumdebit'
                        WHEN 71 THEN 'mcsuperpremiumcredit'
                        WHEN 72 THEN 'mcsuperpremiumdebit'
                        WHEN 73 THEN 'mccommercialcredit'
                        WHEN 74 THEN 'mccommercialdebit'
                        WHEN 75 THEN 'mccommercialpremiumcredit'
                        WHEN 76 THEN 'mccommercialpremiumdebit'
                        WHEN 77 THEN 'mccorporatecredit'
                        WHEN 78 THEN 'mccorporatedebit'
                        WHEN 79 THEN 'mcpurchasingcredit'
                        WHEN 80 THEN 'mcpurchasingdebit'
                        WHEN 81 THEN 'mcfleetcredit'
                        WHEN 82 THEN 'mcfleetdebit'
                        WHEN 83 THEN 'mcpro'
                        WHEN 84 THEN 'mc_applepay'
                        WHEN 85 THEN 'mc_androidpay'
                        WHEN 86 THEN 'bijcard'
                        WHEN 87 THEN 'visastandardcredit'
                        WHEN 88 THEN 'visastandarddebit'
                        WHEN 89 THEN 'visapremiumcredit'
                        WHEN 90 THEN 'visapremiumdebit'
                        WHEN 91 THEN 'visasuperpremiumcredit'
                        WHEN 92 THEN 'visasuperpremiumdebit'
                        WHEN 93 THEN 'visacommercialcredit'
                        WHEN 94 THEN 'visacommercialdebit'
                        WHEN 95 THEN 'visacommercialpremiumcredit'
                        WHEN 96 THEN 'visacommercialpremiumdebit'
                        WHEN 97 THEN 'visacommercialsuperpremiumcredit'
                        WHEN 98 THEN 'visacommercialsuperpremiumdebit'
                        WHEN 99 THEN 'visacorporatecredit'
                        WHEN 100 THEN 'visacorporatedebit'
                        WHEN 101 THEN 'visapurchasingcredit'
                        WHEN 102 THEN 'visapurchasingdebit'
                        WHEN 103 THEN 'visafleetcredit'
                        WHEN 104 THEN 'visafleetdebit'
                        WHEN 105 THEN 'visadankort'
                        WHEN 106 THEN 'visapropreitary'
                        WHEN 107 THEN 'visa_applepay'
                        WHEN 108 THEN 'visa_androidpay'
                        WHEN 109 THEN 'amex_applepay'
                        WHEN 110 THEN 'boletobancario_santander'
                        WHEN 111 THEN 'diners_applepay'
                        WHEN 112 THEN 'directEbanking'
                        WHEN 113 THEN 'discover_applepay'
                        WHEN 114 THEN 'dotpay'
                        WHEN 115 THEN 'idealbn'
                        WHEN 116 THEN 'idealing'
                        WHEN 117 THEN 'idealrabobank'
                        WHEN 118 THEN 'paypal'
                        WHEN 119 THEN 'sepadirectdebit_authcap'
                        WHEN 120 THEN 'depadirectdebit_received'
                        WHEN 121 THEN 'cupcredit'
                        WHEN 122 THEN 'cupdebit'
                        WHEN 123 THEN 'Card on file'
                        WHEN 124 THEN 'MADA'
                        WHEN 125 THEN 'APPLEPAY'
                        WHEN 126 THEN 'PAYWITHGOOGLE'
                        WHEN 127 THEN 'TWINT'
                        WHEN 128 THEN 'ach'
                        WHEN 129 THEN 'paybybank'
                        WHEN 1000 THEN 'Other'
                    END AS "Card Type"
                ,CASE
                        WHEN pr.clearinghouse_id IN (801,602,603,601,605,604,802,803,804,1202,1402,1201) THEN 'CREDIT'
                        ELSE NULL
                END AS "Funding Source"
                ,'FALSE' AS "Bulk Write-Off Exclusion" 
                ,cnl.reason
                ,pr.*
                ,art.*
        FROM 
                Eligible_members em
        JOIN
                evolutionwellness.persons p
                ON p.external_id = em."Membership Number"        
        JOIN
                evolutionwellness.ar_trans art
                ON art.ref_center = em.center
                AND art.ref_id = em.id
                --AND art.ref_subid = em.subid
                AND art.ref_type = 'INVOICE'
        JOIN
                evolutionwellness.payment_request_specifications prs
                ON prs.center = art.payreq_spec_center
                AND prs.id = art.payreq_spec_id
                AND prs.subid = art.payreq_spec_subid
                AND prs.cancelled IS FALSE
        LEFT JOIN
                evolutionwellness.payment_requests pr
                ON pr.center = prs.center
                AND pr.id = prs.id
                AND pr.subid = prs.subid
                AND pr.state = 3     
        LEFT JOIN
                (
                SELECT 
                        count(*),prr.inv_coll_center,prr.inv_coll_id,prr.inv_coll_subid,prr.req_amount
                FROM 
                        evolutionwellness.payment_requests prr
                WHERE 
                        prr.request_type = 6
                GROUP BY prr.inv_coll_center,prr.inv_coll_id,prr.inv_coll_subid,prr.req_amount
                )prr
                ON art.center = prr.inv_coll_center
                AND art.id = prr.inv_coll_id
                AND art.subid = prr.inv_coll_subid
                
        LEFT JOIN
                evolutionwellness.payment_agreements pag
                ON pr.agr_subid = pag.subid
                AND pr.center = pag.center
                AND pag.id = pr.id
                AND pag.active IS TRUE  
        LEFT JOIN
                evolutionwellness.art_match artm
                ON artm.art_paid_center = art.center
                AND artm.art_paid_id = art.id
                AND artm.art_paid_subid = art.subid
        LEFT JOIN
                evolutionwellness.ar_trans artp
                ON artm.art_paying_center = artp.center
                AND artm.art_paying_id = artp.id
                AND artm.art_paying_subid = artp.subid 
        LEFT JOIN
                evolutionwellness.credit_note_lines_mt cnl
                ON cnl.center = artp.ref_center
                AND cnl.id = artp.ref_id
                AND artp.ref_type = 'CREDIT_NOTE'                                                 
        )t
GROUP BY
        t."Country Name"
        ,t."Club Name"
        ,t."Membership Number"
        ,t."Plan Payment Type"
        ,t."Billing Month"
        ,t."Paid Billing"
        ,t."Rebill Count"
        ,t."Charge Amount"
        ,t."Written Off"
        ,t."Outstanding"
        ,t."Invoiced"
        ,t."Refunded"
        ,t."Paid HO"
        ,t."Rebilled Amount"
        ,t."Payment Method Type Code"         
        ,t."Billing Date"
        ,t."Member Status"
        ,t."Action Date"
        ,t."Member Status At End Of Month"
        ,t."Primary Payment Method"
        ,t."Card Type"
        ,t."Funding Source"
        ,t."Bulk Write-Off Exclusion"                                                                    