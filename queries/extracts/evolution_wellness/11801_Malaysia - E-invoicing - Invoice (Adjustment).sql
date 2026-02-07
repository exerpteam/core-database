WITH
params AS
            (
                SELECT
                    /*+ materialize */
                    datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                    c.id AS CENTER_ID,
                    CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'),'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                    centers c
            )      
SELECT DISTINCT
        CASE 
                WHEN cnl.reason IN (16,17,24,26) THEN 'Credit Note' 
                WHEN cnl.reason IN (11,13,14,15,16,17,24,26,37) THEN 'Refund Note' 
        END AS "Document Type*"
        ,inv.center||'inv'||inv.id AS "Original e-Invoice Reference Number*"
        ,cn.center||'cred'||cn.id AS "e-Invoice code/number*"
        ,longtodatec(art.trans_time,art.center) AS "Transaction Date*"
        ,COALESCE(p.external_id,pnew.external_id) AS "Membership Number"
        ,c.external_id AS "Club"
        ,'08' AS "Payment Mode"
        ,NULL AS "Payment Term"
        ,NULL AS "Bill Reference Number"
        ,arti.text AS "Description of Product or Service*"
        ,prod.center||'prod'||prod.id AS "Product ID*"
        ,CASE prod.ptype 
                WHEN 1 THEN '022' 
                WHEN 2 THEN '013' 
                WHEN 4 THEN '013' 
                WHEN 5 THEN '013' 
                WHEN 6 THEN '013' 
                WHEN 7 THEN '013' 
                WHEN 8 THEN '044' 
                WHEN 9 THEN '013' 
                WHEN 10 THEN '013' 
                WHEN 12 THEN '013'  
                WHEN 13 THEN '013' 
                WHEN 14 THEN '013'
                ELSE '013'  
        END AS "Classification*"
        ,1 AS "Quantity*"
        ,artm.amount AS "Unit Price*"
        ,CASE
                WHEN arti.text LIKE  'Late Payment F%' THEN 'E'
                ELSE
                CASE
                        WHEN vat.global_id = 'SVC_NTS_0%' THEN 'E'
                        WHEN vat.global_id = 'SVC_8%' THEN '02'
                        ELSE '06'
                END                       
        END AS "Tax Type*"
        ,CASE
                WHEN vat.global_id = 'SVC_NTS_0%' THEN 'Tax exemption'
                WHEN arti.text LIKE  'Late Payment F%' THEN 'Tax exemption'
                ELSE ''
        END AS "Details of Tax Exemption"
        ,CASE
                WHEN vat.global_id != 'SVC_NTS_0%' THEN artm.amount
                WHEN arti.text LIKE  'Late Payment F%' THEN 0
                ELSE 0
        END AS "Amount Exempted from Tax"
        ,CASE
                WHEN arti.text LIKE  'Late Payment F%' THEN 0
                WHEN COALESCE(vat.global_id,'N/A') = 'SVC_8%' THEN 8
                ELSE 0
        END AS "Tax Rate*"
        ,CASE
                WHEN vat.global_id = 'SVC_8%' THEN artm.amount * 0.08 
                ELSE 0 
        END AS "Tax Amount*"
        ,CASE
                WHEN vat.global_id = 'SVC_8%' THEN artm.amount - (artm.amount * 0.08) 
                ELSE artm.amount
        END AS "Subtotal*"
        ,CASE
                WHEN vat.global_id = 'SVC_8%' THEN artm.amount - (artm.amount * 0.08) 
                ELSE artm.amount
        END AS "Total Excluding Tax*"
        ,artm.amount AS "Total Including Tax*"
        ,artm.amount AS "Total Payable Amount*"
        ,0 AS "Rounding Amount"
        ,CASE
                WHEN invl.total_amount / invl.quantity < invl.product_normal_price THEN ROUND(((invl.product_normal_price - (invl.total_amount / invl.quantity))* 100 / invl.product_normal_price),2)
                ELSE 0
        END AS "Discount Rate"
        ,CASE
                WHEN invl.total_amount / invl.quantity < invl.product_normal_price THEN ROUND((invl.product_normal_price - (invl.total_amount / invl.quantity)),2)
                ELSE 0
        END AS "Discount Amount"
        ,COALESCE(p.fullname,pnew.fullname) AS "Fee/Charge Rate"
        ,0 AS "Fee/Charge Amount"
        ,0 AS "Invoice Additional Discount Amount"
        ,0 AS "Invoice Additional Fee/Charge Amount"      
        ,'Update' AS "Action*" 
FROM
        evolutionwellness.ar_trans art
JOIN
        evolutionwellness.account_receivables ar
        ON art.center = ar.center
        AND art.id = ar.id
        AND ar.ar_type = 4
JOIN
        evolutionwellness.centers c
        ON art.center = c.id           
JOIN
        evolutionwellness.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
LEFT JOIN 
        evolutionwellness.person_ext_attrs peaEmail
        ON peaEmail.personcenter = p.center
        AND peaEmail.personid = p.id
        AND peaEmail.name = '_eClub_Email'    
LEFT JOIN 
        evolutionwellness.person_ext_attrs peaMobile
        ON peaMobile.personcenter = p.center
        AND peaMobile.personid = p.id
        AND peaMobile.name = '_eClub_PhoneSMS'         
JOIN
        evolutionwellness.credit_notes cn
        ON cn.center = art.ref_center
        AND cn.id = art.ref_id
        AND art.ref_type = 'CREDIT_NOTE' 
JOIN
        evolutionwellness.credit_note_lines_mt cnl
        ON cn.center = cnl.center
        AND cn.id = cnl.id    
JOIN
        evolutionwellness.art_match artm
        ON artm.art_paying_center = art.center
        and artm.art_paying_id = art.id
        AND artm.art_paying_subid = art.subid  
JOIN
        evolutionwellness.ar_trans arti
        ON arti.center = artm.art_paid_center
        AND arti.id = artm.art_paid_id
        AND arti.subid = artm.art_paid_subid 
LEFT JOIN
        evolutionwellness.invoices inv
        ON inv.center = arti.ref_center
        AND inv.id = arti.ref_id
LEFT JOIN
        evolutionwellness.invoice_lines_mt invl
        ON invl.center = inv.center
        AND invl.id = inv.id
        AND invl.total_amount != 0
LEFT JOIN
        evolutionwellness.products prod
        ON prod.center = invl.productcenter
        AND prod.id = invl.productid 
LEFT JOIN
        evolutionwellness.product_account_configurations pac
        ON pac.id = prod.product_account_config_id  
LEFT JOIN
        evolutionwellness.accounts ac
        ON ac.globalid = pac.sales_account_globalid
        AND ac.center = prod.center 
LEFT JOIN
        evolutionwellness.account_vat_type_group vat
        ON vat.id = ac.account_vat_type_group_id
        AND vat.account_center = ac.center
        AND vat.account_id = ac.id    
LEFT JOIN
        evolutionwellness.persons pnew
        ON pnew.center = p.current_person_center
        AND pnew.id = p.current_person_id 
JOIN
        params
        ON params.center_id = art.center                                                      
WHERE
        cnl.reason IN (11,13,14,15,16,17,24,26,37)
        AND
        art.center IN (:Scope)
        AND
        art.trans_time BETWEEN params.FromDate AND params.ToDate  