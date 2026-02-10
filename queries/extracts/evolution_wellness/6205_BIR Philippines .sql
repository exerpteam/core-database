-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate                        
              FROM
                  centers c
          )
SELECT
        t."A"
        ,t."B"
        ,t."C"
        ,t."D"
        ,t."E"
        ,t."F"
        ,t."G"
        ,t."H"
        ,t."I"
        ,t."J"
        ,SUM(t."J1") AS "K"
        ,SUM(t."K1") AS "L"
        ,SUM(t."L1") AS "M"
        ,SUM(t."M1") AS "N"
        ,COUNT(*)::text AS "O"
        ,t."Month of Transaction"::text AS "P"
        ,'' AS "Q"
FROM
        (
        SELECT DISTINCT 
                'A' AS "A"
                ,'S' AS "B"
                ,'201135912' AS "C"
                ,'FITNESS FIRST PHILIPPINES INC.' AS "D"
                ,'' AS "E"
                ,'' AS "F"
                ,'' AS "G"
                ,'17TH FLR SM AURA TOWER OFFICE' AS "H"
                ,'26TH ST CORNER MCKINLEY PARKWAY BONIFACIO GLOBAL CITY' AS "I"
                ,'TAGUIG CITY' AS "J"
                ,CASE
                        WHEN vat.global_id = 'VAT_SUS_OUT_0%' THEN invl.net_amount
                        ELSE 0 
                END AS "J1"
                ,CASE
                        WHEN vat.global_id = 'VAT_SUS_OUT_0%' THEN invl.net_amount
                        ELSE 0 
                END AS "K1"
                ,CASE
                        WHEN vat.global_id = 'VAT_OUT_12%' THEN invl.net_amount
                        ELSE 0
                END AS "L1"
                ,invl.total_amount - invl.net_amount "M1"
                ,(date_trunc('month', CURRENT_DATE) + interval '1 month - 1 day')::date AS "Month of Transaction"
                
        FROM 
                evolutionwellness.persons p
        JOIN
                evolutionwellness.invoices inv
                ON p.center = inv.payer_center
                AND p.id = inv.payer_id
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
        JOIN
                params
                ON params.center_id = inv.center                   
        WHERE
                p.center IN (:Scope)
                AND
                inv.entry_time BETWEEN params.FromDate AND params.ToDate
        )t
GROUP BY
        t."A"
        ,t."B"
        ,t."C"
        ,t."D"
        ,t."E"
        ,t."F"
        ,t."G"
        ,t."H"
        ,t."I"
        ,t."J"
        ,t."Month of Transaction"    
UNION ALL                        
SELECT
        t1."A"
        ,t1."B"
        ,t1."C"
        ,t1."D"
        ,t1."E"
        ,t1."F"
        ,t1."G"
        ,t1."H"
        ,t1."I"
        ,t1."J"::text AS "J"
        ,t1."K"
        ,t1."L"
        ,t1."M"
        ,t1."N"
        ,t1."O"::text AS "O"
        ,t1."P"
        ,t1."Q"   
FROM
        (        
        SELECT DISTINCT 
                'D' AS "A"
                ,'S' AS "B"
                ,p.resident_id AS "C"
                ,'' AS "D"
                ,p.lastname AS "E"
                ,p.firstname AS "F"
                ,'' AS "G"
                ,p.address1 AS "H"
                ,p.address2 AS "I"
                ,CASE
                        WHEN vat.global_id = 'VAT_SUS_OUT_0%' THEN invl.net_amount
                        ELSE 0 
                END AS "J"
                ,CASE
                        WHEN vat.global_id = 'VAT_SUS_OUT_0%' THEN invl.net_amount
                        ELSE 0 
                END AS "K"
                ,CASE
                        WHEN vat.global_id = 'VAT_OUT_12%' THEN invl.net_amount
                        ELSE 0
                END AS "L"
                ,invl.total_amount - invl.net_amount "M"
                ,201135912 AS "N"
                ,(date_trunc('month', CURRENT_DATE) + interval '1 month - 1 day')::date AS "O"
                ,'' AS "P"
                ,'' AS "Q"     
        FROM 
                evolutionwellness.persons p
        JOIN
                evolutionwellness.invoices inv
                ON p.center = inv.payer_center
                AND p.id = inv.payer_id
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
        JOIN
                params
                ON params.center_id = inv.center                   
        WHERE
                p.center IN (:Scope)
                AND
                inv.entry_time BETWEEN params.FromDate AND params.ToDate
        )t1                
                    