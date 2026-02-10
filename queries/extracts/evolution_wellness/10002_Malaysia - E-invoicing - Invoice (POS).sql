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
    ),
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
        t1."e-Invoice Code/Number*"
        ,t1."Transaction Date*"
        ,t1."Membership Number*"
        ,t1."Club*"
        ,t1."Payment Mode"
        ,t1."Payment Term"
        ,t1."Bill Reference Number"
        ,t1."Description of Product or Service*"
        ,t1."Product ID*"
        ,t1."Classification*"
        ,t1."Quantity*"
        ,t1."Unit Price*"
        ,t1."Tax Type*"               
        ,t1."Details of Tax Exemption"
        ,CASE
                WHEN t1."Details of Tax Exemption" = 'Tax exemption' THEN t1."Subtotal*"
                ELSE 0
        END AS "Amount Exempted from Tax"                
        ,t1."Tax Rate*"
        ,t1."Tax Amount*"
        ,t1."Subtotal*"
        ,t1."Total Excluding Tax*"
        ,t1."Total Including Tax*"
        ,t1."Total Payable Amount*"
        ,NULL AS "Rounding Amount"
        ,NULL AS "Discount Rate"
        ,NULL AS "Discount Amount"
        ,NULL AS "Fee/Charge Rate"
        ,NULL AS "Fee/Charge Amount"
        ,NULL AS "Invoice Additional Discount Amount"
        ,NULL AS "Invoice Additional Fee/Charge Amount"
        ,t1."Action*"  
        --,t1.type
FROM
        (                
        SELECT DISTINCT
                t."e-Invoice Code/Number*"
                ,TO_CHAR(t."Transaction Date*", 'YYYY-MM-DD') AS "Transaction Date*"
                ,t."Membership Number*"
                ,t."Club*"
                ,t."Payment Mode"
                ,t."Payment Term"
                ,t."Bill Reference Number"
                ,t."Description of Product or Service*"
                ,t."Product ID*"
                ,t."Classification*"
                ,t."Quantity*"
                ,t."Unit Price*"
                ,CASE
                        WHEN t."Description of Product or Service*" like 'Late Payment F%' THEN 'E'
                        ELSE t."Tax Type*"
                END AS "Tax Type*"               
                ,CASE
                        WHEN t."Description of Product or Service*" like 'Late Payment F%' THEN 'Tax exemption'
                        ELSE
                                CASE
                                        WHEN t."Tax Rate*" = 'SVC_8%' THEN NULL
                                        ELSE 'Tax exemption'
                                END                                
                END AS "Details of Tax Exemption"
                ,CASE
                        WHEN t."Tax Rate*" = 'SVC_8%' THEN 8
                        ELSE 0
                END AS "Tax Rate*"
                ,t."Tax Amount*"
                ,t."Subtotal*"
                ,t."Total Excluding Tax*"
                ,t."Total Including Tax*"
                ,t."Total Payable Amount*"
                ,'Create' AS "Action*"
        FROM
                (                        
                        SELECT DISTINCT
                                art.ref_center||'ar'||art.ref_id||'tr'||art.ref_subid AS "e-Invoice Code/Number*"
                                ,longtodatec(art.trans_time,art.center) AS "Transaction Date*"
                                ,COALESCE(p.external_id,pnew.external_id) AS "Membership Number*"
                                ,c.external_id AS "Club*"
                                ,'04' AS "Payment Mode"
                                ,NULL AS "Payment Term"
                                ,NULL AS "Bill Reference Number"
                                ,CASE
                                        WHEN arti.ref_type = 'INVOICE' THEN invl.text
                                        ELSE arti.text                                                      
                                END AS "Description of Product or Service*"
                                ,CASE
                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN acti.center||'ar'||acti.id||'tr'||acti.subid
                                        WHEN arti.ref_type = 'INVOICE' THEN prod.center||'prod'||prod.id                                               
                                END AS "Product ID*"
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
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN artm.amount
                                        ELSE
                                                CASE
                                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN artm.amount
                                                        ELSE invl.total_amount
                                                END                                                         
                                END AS "Unit Price*"
                                ,CASE
                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN 'E'
                                        WHEN vat.global_id = 'SVC_NTS_0%' THEN 'E'
                                        ELSE '02'
                                END AS "Tax Type*"
                                ,CASE
                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN 'Tax exemption'
                                        WHEN vat.global_id = 'SVC_NTS_0%' THEN 'Tax exemption'
                                        ELSE NULL
                                END AS "Details of Tax Exemption"
                                ,COALESCE(vat.global_id,'N/A') AS "Tax Rate*"
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN 
                                                CASE
                                                        WHEN vat.global_id = 'SVC_8%' THEN artm.amount * 0.08
                                                        ELSE 0
                                                END
                                        ELSE
                                                CASE
                                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN 0
                                                        ELSE invl.total_amount - invl.net_amount 
                                                END                                                         
                                END AS "Tax Amount*"
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN 
                                                CASE
                                                        WHEN vat.global_id = 'SVC_8%' THEN artm.amount * 0.92
                                                        ELSE artm.amount
                                                END
                                        ELSE
                                                CASE
                                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN artm.amount
                                                        ELSE invl.net_amount 
                                                END                                                         
                                END AS "Subtotal*"
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN 
                                                CASE
                                                        WHEN vat.global_id = 'SVC_8%' THEN artm.amount * 0.92
                                                        ELSE artm.amount
                                                END
                                        ELSE
                                                CASE
                                                        WHEN arti.ref_type = 'ACCOUNT_TRANS' THEN artm.amount
                                                        ELSE invl.net_amount 
                                                END                                                         
                                END AS "Total Excluding Tax*"
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN artm.amount
                                        ELSE invl.total_amount                                                       
                                END AS "Total Including Tax*"
                                ,CASE
                                        WHEN artm.amount < -arti.amount THEN artm.amount
                                        ELSE invl.total_amount                                                       
                                END AS "Total Payable Amount*"
                                ,'Create' AS "Action*" 
                                ,art.trans_time 
                                ,1 as type
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
                                AND p.sex != 'C'
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
                                evolutionwellness.account_trans act
                                ON act.center = art.ref_center
                                AND act.id = art.ref_id
                                AND act.subid = art.ref_subid
                                AND art.ref_type = 'ACCOUNT_TRANS'
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
                                evolutionwellness.account_trans acti
                                ON acti.center  = arti.ref_center
                                AND acti.id = arti.ref_id
                                AND acti.subid = arti.ref_subid
                                AND arti.ref_type = 'ACCOUNT_TRANS'
                        LEFT JOIN
                                evolutionwellness.invoices inv
                                ON inv.center = arti.ref_center
                                AND inv.id = arti.ref_id
                                AND arti.ref_type = 'INVOICE'
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
                                act.info_type NOT IN (5,11)
                                AND
                                art.center IN (:Scope)
                                AND
                                art.trans_time BETWEEN params.FromDate AND params.ToDate  
                        UNION ALL
                        SELECT
                                DISTINCT
                                inv.center||'inv'||inv.id AS "e-Invoice Code/Number*"
                                ,longtodatec(crt.transtime,crt.center) AS "Transaction Date*"
                                ,COALESCE(p.external_id,pnew.external_id) AS "Membership Number*"
                                ,c.external_id AS "Club*"
                                ,COALESCE(CASE
                                                WHEN icpm.name IS NOT NULL THEN '08' 
                                                ELSE
                                                    CASE crt.CRTTYPE
                                                        WHEN 1 THEN '01'
                                                        WHEN 2 THEN '01'
                                                        WHEN 3 THEN '04'
                                                        WHEN 4 THEN '01'
                                                        WHEN 5 THEN '08'
                                                        WHEN 6 THEN '05'
                                                        WHEN 7 THEN '04'
                                                        WHEN 8 THEN '04'
                                                        WHEN 9 THEN '08'
                                                        WHEN 10 THEN '08'
                                                        WHEN 11 THEN '01'
                                                        WHEN 12 THEN '08'
                                                        WHEN 13 THEN '08'
                                                        WHEN 14 THEN '01'
                                                        WHEN 15 THEN '08'
                                                        WHEN 16 THEN '08'
                                                        WHEN 17 THEN '08'
                                                        WHEN 18 THEN '08'
                                                        WHEN 19 THEN '08'
                                                        WHEN 20 THEN '08'
                                                        WHEN 21 THEN '08'
                                                        WHEN 22 THEN '08'
                                                        WHEN 100 THEN '01'
                                                        WHEN 101 THEN '08'
                                                END                                
                                END) AS "Payment Mode"
                                ,NULL AS "Payment Term"
                                ,NULL AS "Bill Reference Number"
                                ,prod.name AS "Description of Product or Service*"
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
                                ,CASE
                                        WHEN vat.global_id = 'SVC_8%' THEN crt.amount - (crt.amount * 0.08) 
                                        ELSE crt.amount
                                END AS "Unit Price*"
                                ,CASE
                                        WHEN vat.global_id = 'SVC_NTS_0%' THEN 'E'
                                        ELSE '02'
                                END AS "Tax Type*"
                                ,CASE
                                        WHEN vat.global_id = 'SVC_NTS_0%' THEN 'Tax exemption'
                                        ELSE NULL
                                END AS "Details of Tax Exemption"
                                ,COALESCE(vat.global_id,'N/A') AS "Tax Rate*"
                                ,CASE
                                        WHEN vat.global_id = 'SVC_8%' THEN crt.amount * 0.08 
                                        ELSE 0 
                                END AS "Tax Amount*"
                                ,CASE
                                        WHEN vat.global_id = 'SVC_8%' THEN crt.amount - (crt.amount * 0.08) 
                                        ELSE crt.amount
                                END AS "Subtotal*"
                                ,CASE
                                        WHEN vat.global_id = 'SVC_8%' THEN crt.amount - (crt.amount * 0.08) 
                                        ELSE crt.amount
                                END AS "Total Excluding Tax*"
                                ,crt.amount AS "Total Including Tax*"
                                ,crt.amount AS "Total Payable Amount*"
                                ,'Create' AS "Action*"
                                ,crt.transtime  
                                ,2 as type    
                        FROM                                      
                                evolutionwellness.cashregistertransactions crt
                        JOIN
                                evolutionwellness.persons p
                                ON p.center = crt.customercenter
                                AND p.id = crt.customerid
                                AND p.sex != 'C'                        
                        JOIN
                                evolutionwellness.centers c
                                ON crt.center = c.id           
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
                        LEFT JOIN
                                center_config_payment_method_id icpm
                                ON crt.center =icpm.center_id
                                AND crt.config_payment_method_id = icpm.id      
                        JOIN
                                evolutionwellness.invoices inv
                                ON inv.cashregister_center = crt.center
                                AND inv.cashregister_id = crt.id
                                AND inv.paysessionid = crt.paysessionid
                        JOIN
                                evolutionwellness.invoice_lines_mt invl
                                ON invl.center = inv.center
                                AND invl.id = inv.id
                                AND invl.total_amount != 0
                        JOIN
                                evolutionwellness.products prod
                                ON prod.center = invl.productcenter
                                AND prod.id = invl.productid 
                        JOIN
                                evolutionwellness.product_account_configurations pac
                                ON pac.id = prod.product_account_config_id  
                        JOIN
                                evolutionwellness.accounts ac
                                ON ac.globalid = pac.sales_account_globalid
                                AND ac.center = prod.center 
                        JOIN
                                evolutionwellness.account_vat_type_group vat
                                ON vat.id = ac.account_vat_type_group_id
                                AND vat.account_center = ac.center
                                AND vat.account_id = ac.id    
                        JOIN
                                evolutionwellness.persons pnew
                                ON pnew.center = p.current_person_center
                                AND pnew.id = p.current_person_id 
                        JOIN
                                params
                                ON params.center_id = crt.center                               
                        WHERE
                                crt.center IN (:Scope)
                                AND
                                crt.transtime BETWEEN params.FromDate AND params.ToDate  
                )t  
        )t1                                      
             