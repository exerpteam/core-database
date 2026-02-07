WITH
        params AS
        (
                SELECT
                        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                        c.id AS CENTER_ID,
                        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                        centers c
        )
SELECT
        longtodatec(inv.entry_time,inv.center) AS Date
        ,p.center||'p'||p.id AS "Exerp ID"
        ,c.shortname AS Location
        ,p.fullname AS Name
        ,invl.text AS "Products"
        ,invl.total_amount AS "Payment Amount"
        ,CASE
                WHEN artp.employeecenter IS NULL THEN 'Direct Debit'
                ELSE 'Credit Card'
        END AS "Payment Method"  
        ,CASE
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp2202' THEN 'Website'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp20601' THEN 'Mobile App'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp19603' THEN 'WebApps'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp2605' THEN 'Online Join'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp409' THEN 'MWC'        
        END AS "Payment Source"             
FROM
        fernwood.invoices inv
JOIN
        fernwood.invoice_lines_mt invl
        ON invl.center = inv.center
        AND inv.id = invl.id
        AND invl.reason NOT IN (2,6)
JOIN
        persons p
        ON p.center = inv.payer_center                      
        AND p.id = inv.payer_id
JOIN
        fernwood.ar_trans art
        ON art.ref_center = invl.center
        AND art.ref_id = invl.id
        AND art.ref_type = 'INVOICE'
JOIN
        art_match artm
        ON artm.art_paid_center = art.center
        AND artm.art_paid_id = art.id
        AND artm.art_paid_subid = art.subid
        AND artm.cancelled_time IS NULL 
JOIN
        fernwood.ar_trans artp
        ON artp.center = artm.art_paying_center
        AND artp.id = artm.art_paying_id
        AND artp.subid = artm.art_paying_subid               
JOIN
        params
        ON params.center_id = inv.center 
JOIN
        fernwood.centers c
        ON c.id = inv.center                            
WHERE
        inv.employee_center ||'emp'|| inv.employee_id  IN ('100emp409','100emp2202','100emp20601','100emp19603','100emp2605') 
        AND
        inv.entry_time BETWEEN params.FromDate AND params.ToDate
        AND 
        inv.center IN (:Scope)
UNION ALL
SELECT 
        longtodatec(art.trans_time,art.center) AS Date
        ,p.center||'p'||p.id AS "Exerp ID"
        ,c.shortname AS Location
        ,p.fullname AS Name
        ,art.text AS "Products"
        ,art.amount AS "Payment Amount"
        ,CASE
                WHEN art.employeecenter IS NULL THEN 'Direct Debit'
                ELSE 'Credit Card'
        END AS "Payment Method"  
        ,CASE
                WHEN art.employeecenter ||'emp'|| art.employeeid = '100emp2202' THEN 'Website'
                WHEN art.employeecenter ||'emp'|| art.employeeid = '100emp20601' THEN 'Mobile App'
                WHEN art.employeecenter ||'emp'|| art.employeeid = '100emp19603' THEN 'WebApps'
                WHEN art.employeecenter ||'emp'|| art.employeeid = '100emp2605' THEN 'Online Join'
                WHEN art.employeecenter ||'emp'|| art.employeeid = '100emp409' THEN 'MWC'        
        END AS "Payment Source"  
FROM 
        fernwood.persons p
JOIN
        fernwood.account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
JOIN
        fernwood.ar_trans art
        ON art.center = ar.center
        AND art.id = ar.id
        AND art.ref_type = 'ACCOUNT_TRANS'
JOIN
        fernwood.centers c
        ON c.id = p.center
JOIN
        params
        ON params.center_id = art.center                 
WHERE
        art.employeecenter ||'emp'|| art.employeeid  IN ('100emp409','100emp2202','100emp20601','100emp19603','100emp2605') 
        AND
        art.trans_time BETWEEN params.FromDate AND params.ToDate
        AND
        art.center IN (:Scope)
UNION ALL
SELECT         
        longtodatec(inv.entry_time,inv.center) AS Date
        ,p.center||'p'||p.id AS "Exerp ID"
        ,c.shortname AS Location
        ,p.fullname AS Name
        ,invl.text AS "Products"
        ,invl.total_amount AS "Payment Amount"
        ,'Credit Card' AS "Payment Method"  
        ,CASE
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp2202' THEN 'Website'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp20601' THEN 'Mobile App'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp19603' THEN 'WebApps'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp2605' THEN 'Online Join'
                WHEN inv.employee_center ||'emp'|| inv.employee_id = '100emp409' THEN 'MWC'        
        END AS "Payment Source"    
FROM
        fernwood.invoices inv
JOIN
        fernwood.invoice_lines_mt invl
        ON invl.center = inv.center
        AND inv.id = invl.id
        AND invl.reason != 2
JOIN
        fernwood.cashregistertransactions crt
        ON crt.paysessionid = inv.paysessionid
JOIN
        fernwood.cashregisters cr
        ON cr.center = crt.center
        AND cr.id = crt.id
        AND cr.name like 'Web%'               
JOIN
        persons p
        ON p.center = inv.payer_center                      
        AND p.id = inv.payer_id
JOIN
        params
        ON params.center_id = inv.center 
JOIN
        fernwood.centers c
        ON c.id = inv.center
WHERE 
        inv.employee_center ||'emp'|| inv.employee_id  IN ('100emp409','100emp2202','100emp20601','100emp19603','100emp2605')    
        AND
        inv.entry_time BETWEEN params.FromDate AND params.ToDate  
        AND
        inv.center IN (:Scope)                 
  
               