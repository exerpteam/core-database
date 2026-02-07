-- #195349 To fix the ERROR: date field value out of range: 2025-13-01
 
WITH params AS MATERIALIZED
(
        SELECT
                t1.*,
                dateToLongC(TO_CHAR(MAKE_DATE(FromYear,FromMonth, 1),'YYYY-MM-DD'),t1.center_id) AS fromDateLong,
                dateToLongC(TO_CHAR(MAKE_DATE(FromYear,FromMonth, 1) - interval '1 days','YYYY-MM-DD'),t1.center_id) AS fromDateLongBeforeRenewal,
                dateToLongC(TO_CHAR((MAKE_DATE(FromYear, FromMonth, 1) + INTERVAL '1 month'),'YYYY-MM-DD'),t1.center_id)-1 AS toDateLong,
                MAKE_DATE(FromYear,FromMonth, 1) AS fromDate,
                (MAKE_DATE(FromYear, FromMonth, 1) + INTERVAL '1 month' - INTERVAL '1 day') AS toDate,
                MAKE_DATE(FromYear,FromMonth, 1) AS printDate
        FROM
        (
                SELECT
                        :month AS FromMonth,
                        c.id AS center_id,
                        :year AS FromYear,
                        c.country,
                        c.name AS clubname                                      
                FROM centers c
                WHERE
                        c.id IN (:Scope)
        ) t1
),
art_renewal_transactions AS
(
        SELECT
                ar.customercenter,
                ar.customerid,
                ar.center AS ar_center,
                ar.id AS ar_id,
                art.amount,
                art.text,
                art.center,
                art.id,
                art.subid,
                art.entry_time,
                art.trans_time
        FROM evolutionwellness.ar_trans art
        JOIN params par ON art.center = par.center_id
        JOIN evolutionwellness.account_receivables ar ON ar.center = art.center AND ar.id = art.id 
        JOIN evolutionwellness.persons p ON ar.customercenter = p.center AND ar.customerid = p.id AND p.sex != 'C'
        WHERE
                (art.text like '%(Auto Renewal)' OR art.text like '%(Perpanjangan Otomatis)' OR art.text like'%(การต่ออายุอัตโนมัติ)')
                AND art.trans_time between par.fromDateLong AND par.toDateLong
),
outstanding_balance AS
(
        SELECT
                sm.customercenter,
                sm.customerid,
                SUM(art.amount) AS balance_before_period
        FROM 
        (
                SELECT
                        DISTINCT 
                        artrt.customercenter,
                        artrt.customerid,
                        artrt.ar_center,
                        artrt.ar_id    
                FROM art_renewal_transactions artrt
                        
        ) sm
        JOIN evolutionwellness.ar_trans art ON sm.ar_center = art.center AND sm.ar_id = art.id
        JOIN params par ON art.center = par.center_id
        WHERE
                art.entry_time < par.fromDateLongBeforeRenewal
        GROUP BY
                sm.customercenter,
                sm.customerid
),
payment_requests_from_period AS
(
        SELECT
                em.customercenter,
                em.customerid,
                pr.req_date,
                pr.state,
                pr.req_amount,
                pr.xfr_amount,
                pr.request_type,
                pr.ref,
                pr.clearinghouse_id,
                CASE pr.STATE WHEN 1 THEN 'New' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Done' WHEN 4 THEN 'Done, manual' WHEN 5 THEN 'Rejected, clearinghouse' WHEN 6 THEN 'Rejected, bank' WHEN 7 THEN 'Rejected, debtor' WHEN 8 THEN 'Cancelled' WHEN 10 THEN 'Reversed, new' WHEN 11 THEN 'Reversed , sent' WHEN 12 THEN 'Failed, not creditor' WHEN 13 THEN 'Reversed, rejected' WHEN 14 THEN 'Reversed, confirmed' WHEN 17 THEN 'Failed, payment revoked' WHEN 18 THEN 'Done Partial' WHEN 19 THEN 'Failed, Unsupported' WHEN 20 THEN 'Require approval' WHEN 21 THEN 'Fail, debt case exists' WHEN 22 THEN 'Failed, timed out' ELSE 'Undefined' END AS payment_request_state,
                pr.agr_subid,
                pr.center,
                pr.id
        FROM 
        (
                SELECT
                        DISTINCT
                                artrt.ar_center,
                                artrt.ar_id,
                                artrt.customercenter,
                                artrt.customerid
                FROM art_renewal_transactions artrt
        ) em
        JOIN evolutionwellness.payment_requests pr ON em.ar_center = pr.center AND em.ar_id = pr.id
        JOIN params par ON pr.center = par.center_id
        WHERE
                pr.request_type IN (1,6)
                AND pr.req_date BETWEEN par.fromDate AND par.toDate
),
settlement_transactions AS
(
        SELECT
                artrt.customercenter,
                artrt.customerid,
                artrt.text,
                artrt.entry_time AS art_entry_Time,
                artm.cancelled_time,
                art2.amount,
                art2.text AS text2,
                art2.entry_time AS art2_entry_Time,
                p.fullname,
                art2.ref_center,
                art2.ref_id,
                art2.ref_subid,
                emp.center||'emp'||emp.id AS employee,
                art2.info
        FROM art_renewal_transactions artrt
        LEFT JOIN evolutionwellness.art_match artm ON artrt.center = artm.art_paid_center AND artrt.id = artm.art_paid_id AND artrt.subid = artm.art_paid_subid AND artm.cancelled_time IS NULL
        LEFT JOIN evolutionwellness.ar_trans art2 On art2.center = artm.art_paying_center AND art2.id = artm.art_paying_id AND art2.subid = artm.art_paying_subid
        LEFT JOIN evolutionwellness.employees emp ON art2.employeecenter = emp.center AND art2.employeeid = emp.id
        LEFT JOIN evolutionwellness.persons p ON emp.personcenter = p.center AND emp.personid = p.id 
)

SELECT DISTINCT
        par.country                                                                     AS "Country Name",
        par.clubname                                                                    AS "Club Name",
        c.name                                                                          AS "Current Club Name",
        cp.external_id                                                                  AS "Membership Number",        
        'Pay Monthly'                                                                   AS "Plan Payment Type",
        TO_CHAR(par.fromDate,'MM-YYYY')                                                 AS "Billing Month",
        COALESCE(prp.xfr_amount,0)                                                      AS "Paid Billing",
        COALESCE(prr.xfr_amount,0)                                                      AS "Paid re-billing",
        COALESCE(prr_count.num_rep,0)                                                   AS "Rebill Count",
        art.total_amount                                                                AS "Charge Amount",
        COALESCE(woff.writeoff_amount,0)                                                AS "Written Off",
        CASE
                WHEN ob.balance_before_period < 0 THEN  ob.balance_before_period
                ELSE 0
        END                                                                             AS "Outstanding",
        0                                                                               AS "Invoiced",
        0                                                                               AS "Refunded",
        COALESCE(pia.pia_amount,club.paidclub,0)                                        AS "Paid Club",
        COALESCE(api.apipaid,0)                                                         AS "Paid HO",
        COALESCE(piad.pia_amount,0)                                                     AS "Advanced Amount",
        CASE
                WHEN mpa.center IS NOT NULL THEN NULL
                ELSE
                        CASE
                                WHEN ch.id IN (801,602,601,603,2801,604,3201,605,3001,802,803,804,1202,1402,1201) THEN 'CC'
                                WHEN ch.id IN (1401,1602,1801,2001,3601,1601,3801,1001) THEN 'DD'
                        ELSE 'Other'
                        END                        
        END                                                                             AS "Payment Method Type Code",
        longtodatec(art.max_bookdate, art.customercenter)::DATE                         AS "Billing Date",
        CASE p.status 
                WHEN 0 THEN 'LEAD'
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END                                                                             AS "Member Status",
        longtodatec(paiddate.paiddate,paiddate.customercenter)::DATE                    AS "Billing Payment Date",
        par.printDate                                                                   AS "Action Date",
        CASE p.status 
                WHEN 0 THEN 'LEAD'
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END                                                                             AS "Member Status At End Of Month",
        CASE
                WHEN mpa.center IS NOT NULL THEN NULL
                ELSE
                        CASE
                                WHEN ch.id IN (801,602,601,603,2801,604,3201,605,3001,802,803,804,1202,1402,1201) THEN 'Credit Card'
                                WHEN ch.id IN (1401,1602,1801,2001,3601,1601,3801,1001) THEN 'Direct Debit'
                        ELSE 'CASH'
                        END                        
        END                                                                             AS "Payment Method Type Code",
        CASE pag.credit_card_type
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
        END                                                                             AS "Card Type",
        CASE
                WHEN mpa.center IS NOT NULL THEN NULL
                ELSE
                        CASE
                                WHEN ch.id IN (801,602,601,603,2801,604,3201,605,3001,802,803,804,1202,1402,1201) THEN 'CREDIT'
                                ELSE NULL
                        END                                
        END                                                                             AS "Funding Source",
        'FALSE'                                                                         AS "Bulk Write-Off Exclusion"      
FROM 
(
        SELECT
                ttt.customercenter,
                ttt.customerid,
                ttt.ar_center,
                ttt.ar_id,
                SUM(ttt.amount) AS total_amount,
                MAX(ttt.trans_time) AS max_bookdate
        FROM art_renewal_transactions ttt
        JOIN evolutionwellness.persons p ON ttt.customercenter = p.center AND ttt.customerid = p.id
        JOIN evolutionwellness.persons cp ON cp.center = p.transfers_current_prs_center AND cp.id = p.transfers_current_prs_id
        GROUP BY
                ttt.customercenter,
                ttt.customerid,
                ttt.ar_center,
                ttt.ar_id
) art
JOIN params par ON art.ar_center = par.center_id
JOIN evolutionwellness.persons p ON art.customercenter = p.center AND art.customerid = p.id
JOIN evolutionwellness.persons cp ON cp.center = p.transfers_current_prs_center AND cp.id = p.transfers_current_prs_id
JOIN evolutionwellness.centers c ON cp.center = c.id
LEFT JOIN payment_requests_from_period prp ON art.customercenter = prp.customercenter AND art.customerid = prp.customerid AND prp.state = 3 AND prp.request_type = 1
LEFT JOIN payment_requests_from_period prpch ON art.customercenter = prpch.customercenter AND art.customerid = prpch.customerid AND prpch.request_type = 1
LEFT JOIN evolutionwellness.clearinghouses ch ON ch.id = prpch.clearinghouse_id
LEFT JOIN evolutionwellness.payment_agreements pag ON prp.agr_subid = pag.subid AND prp.center = pag.center AND prp.id = pag.id AND pag.active IS TRUE AND prp.request_type = 1   
LEFT JOIN 
(
        SELECT
                pri.customercenter,
                pri.customerid,
                SUM(pri.xfr_amount) AS xfr_amount
        FROM payment_requests_from_period pri
        WHERE
                pri.request_type = 6
                AND pri.state = 3
        GROUP BY 
                pri.customercenter,
                pri.customerid                 
) prr ON art.customercenter = prr.customercenter AND art.customerid = prr.customerid
LEFT JOIN 
(
        SELECT
                pri.customercenter,
                pri.customerid,
                COUNT(*) AS num_rep
        FROM payment_requests_from_period pri
        WHERE
                pri.request_type = 6
        GROUP BY
                pri.customercenter,
                pri.customerid
) prr_count ON art.customercenter = prr_count.customercenter AND art.customerid = prr_count.customerid
LEFT JOIN outstanding_balance ob
        ON art.customercenter = ob.customercenter AND art.customerid = ob.customerid
LEFT JOIN 
(
        SELECT
                wo.customercenter,
                wo.customerid,
                SUM(wo.amount) AS writeoff_amount
        FROM settlement_transactions wo
        WHERE 
                (
                wo.employee NOT IN ('100emp1','999emp207')
                AND
                wo.text2 NOT LIKE 'Payment into account'
                AND
                wo.text2 NOT LIKE 'Bank Transfer%'
                AND
                wo.info IS NULL
                AND
                wo.ref_subid IS NOT NULL
                )
                OR
                wo.text2 like '%write off%'
        GROUP BY
                wo.customercenter,
                wo.customerid
) woff ON woff.customercenter = art.customercenter AND woff.customerid = art.customerid
LEFT JOIN 
(
        SELECT
                st.customercenter,
                st.customerid,
                SUM(st.amount) AS pia_amount
        FROM settlement_transactions st
        WHERE 
                st.text2 = 'Payment into account'
		OR 
		st.text2 LIKE 'Pembayaran ke rekening%'
        GROUP BY
                st.customercenter,
                st.customerid
) pia ON pia.customercenter = art.customercenter AND pia.customerid = art.customerid
LEFT JOIN 
(
        SELECT
                st.customercenter,
                st.customerid,
                SUM(st.amount) AS pia_amount
        FROM settlement_transactions st
        WHERE 
                st.art_entry_Time > st.art2_entry_Time
        GROUP BY
                st.customercenter,
                st.customerid
) piad ON piad.customercenter = art.customercenter AND piad.customerid = art.customerid
LEFT JOIN 
(
        SELECT
                st.customercenter,
                st.customerid,
                MAX(st.art2_entry_Time) AS paiddate
        FROM settlement_transactions st
        GROUP BY
                st.customercenter,
                st.customerid
) paiddate ON paiddate.customercenter = art.customercenter AND paiddate.customerid = art.customerid
LEFT JOIN
(
        SELECT
                *
        FROM    
                evolutionwellness.cashcollectioncases cc
        WHERE
                cc.missingpayment IS FALSE
                AND
                cc.closed IS FALSE
) mpa ON mpa.personcenter = art.customercenter AND mpa.personid = art.customerid
LEFT JOIN 
(
        SELECT
                st.customercenter,
                st.customerid,
                SUM(st.amount) AS paidclub
        FROM settlement_transactions st
        JOIN evolutionwellness.account_trans act 
        ON act.center = st.ref_center 
        AND act.id = st.ref_id 
        AND act.subid = st.ref_subid
        WHERE
                act.info_type = 6
        GROUP BY
                st.customercenter,
                st.customerid
) club ON club.customercenter = art.customercenter AND club.customerid = art.customerid
LEFT JOIN 
(
        SELECT
                st.customercenter,
                st.customerid,
                SUM(st.amount) AS apipaid
        FROM settlement_transactions st
        WHERE
                st.fullname like '%API%'
                OR
		st.text2 LIKE 'Bank Transfer%'
        GROUP BY
                st.customercenter,
                st.customerid
) api ON api.customercenter = art.customercenter AND api.customerid = art.customerid
WHERE
        art.total_amount != 0