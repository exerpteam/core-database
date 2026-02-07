SELECT DISTINCT
        p.center||'p'||p.id as PersonId
        ,p.external_id
        ,art.amount
        ,art.due_date
        ,'No' AS "PWD/SC"
        ,'200' AS "Late Payment Fee"
FROM
        evolutionwellness.ar_trans art
JOIN
        evolutionwellness.account_receivables ar
        ON art.center = ar.center
        AND art.id = ar.id
        AND ar.ar_type = 4
JOIN
        evolutionwellness.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
JOIN
        evolutionwellness.centers c
        ON c.id = p.center                                                    
WHERE                
        c.country = 'PH'
        AND
        art.status != 'CLOSED'
        AND
        art.due_date = date_trunc('month', current_date)::date
        AND 
        art.ref_type = 'INVOICE'
        AND
        p.sex != 'C'
        AND
        art.text like '%(Auto Renewal)'
        AND
        p.external_id NOT IN (
                                SELECT DISTINCT
                                        p.external_id
                                FROM
                                        evolutionwellness.ar_trans art
                                JOIN
                                        evolutionwellness.account_receivables ar
                                        ON art.center = ar.center
                                        AND art.id = ar.id
                                        AND ar.ar_type = 4
                                JOIN
                                        evolutionwellness.persons p
                                        ON p.center = ar.customercenter
                                        AND p.id = ar.customerid
                                JOIN
                                        evolutionwellness.centers c
                                        ON c.id = p.center
                                JOIN
                                        evolutionwellness.invoices inv
                                        ON inv.center = art.ref_center
                                        AND inv.id = art.ref_id
                                JOIN
                                        evolutionwellness.invoice_lines_mt invl
                                        ON inv.center = invl.center
                                        AND inv.id = invl.id 
                                JOIN
                                        evolutionwellness.products prod
                                        ON prod.center = invl.productcenter
                                        AND prod.id = invl.productid
                                        AND prod.name LIKE '%PWD%'                                                         
                                WHERE                
                                        c.country = 'PH'
                                        AND
                                        art.status != 'CLOSED'
                                        AND
                                        art.due_date = date_trunc('month', current_date)::date
                                        AND 
                                        art.ref_type = 'INVOICE'
                                        AND
                                        p.sex != 'C'
                                        AND
                                        art.text like '%(Auto Renewal)'
        )
UNION ALL                                                
SELECT DISTINCT
        p.center||'p'||p.id as PersonId
        ,p.external_id
        ,art.amount
        ,art.due_date
        ,'Yes' AS "PWD/SC"
        ,'142.86' AS "Late Payment Fee"
FROM
        evolutionwellness.ar_trans art
JOIN
        evolutionwellness.account_receivables ar
        ON art.center = ar.center
        AND art.id = ar.id
        AND ar.ar_type = 4
JOIN
        evolutionwellness.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
JOIN
        evolutionwellness.centers c
        ON c.id = p.center
JOIN
        evolutionwellness.invoices inv
        ON inv.center = art.ref_center
        AND inv.id = art.ref_id
JOIN
        evolutionwellness.invoice_lines_mt invl
        ON inv.center = invl.center
        AND inv.id = invl.id 
JOIN
        evolutionwellness.products prod
        ON prod.center = invl.productcenter
        AND prod.id = invl.productid
        AND prod.name LIKE '%PWD%'                                                      
WHERE                
        c.country = 'PH'
        AND
        art.status != 'CLOSED'
        AND
        art.due_date = date_trunc('month', current_date)::date
        AND 
        art.ref_type = 'INVOICE'
        AND
        p.sex != 'C'
        AND
        art.text like '%(Auto Renewal)'
ORDER BY 1

