WITH
    shifts AS
    (
        SELECT DISTINCT
            crl.cash_register_center,
            crl.cash_register_id,
            CASE
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN longtodatec(log_time,crl.cash_register_center)
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN longtodatec(lag(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC),crl.cash_register_center)
            END AS register_close,
            CASE
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN longtodatec(log_time,crl.cash_register_center)
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN longtodatec(lead(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC),crl.cash_register_center)
            END AS register_open,
            CASE
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN log_time
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN lag(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC)
            END AS register_close_long,
            CASE
                WHEN log_type = 'OPEN_CASH_REGISTER'
                THEN log_time
                WHEN log_type = 'CLOSE_CASH_REGISTER'
                THEN lead(log_time) over (partition BY crl.cash_register_center,
                    crl.cash_register_id ORDER BY log_time DESC)
            END AS register_open_long
        FROM
            evolutionwellness.cash_register_log crl
        WHERE
            crl.cash_register_center IN (:Scope)
        AND longtodateC(log_time,crl.cash_register_center)::DATE BETWEEN :From AND :To
        AND log_type IN('CLOSE_CASH_REGISTER',
                        'OPEN_CASH_REGISTER')
    )  
SELECT
        t."Club"
        ,t."Club Number"	
        ,t."Club Code"
        ,t."Operator"	
        ,t."Shift Start Time"
        ,t."Shift End Time"
        ,t."Transaction Day"
        ,t."Workstation"
        ,t."Item"
        ,SUM(t."Quantity") AS "Quantity"
        ,SUM(t."Total Sale Amount") AS "Total Sale Amount"
        ,SUM(t."Total Tax Amount") AS "Total Tax Amount"
        ,t."Tax Rate"        
FROM
        (        
        SELECT
                c.name AS "Club"
                ,c.id AS "Club Number"	
                ,c.external_id AS "Club Code"
                ,p.fullname AS "Operator"	
                ,crl.register_open AS "Shift Start Time"
                ,crl.register_close AS "Shift End Time"
                ,TO_CHAR(longtodatec(crt.transtime,crt.center),'YYYY-MM-DD') AS "Transaction Day"
                ,crl.cash_register_center||'cr'||crl.cash_register_id AS "Workstation"
                ,CASE  
                        WHEN PTYPE = 1 THEN 'Goods' 
                        WHEN PTYPE = 2 THEN 'Service' 
                        WHEN PTYPE = 4 THEN 'Clipcard' 
                        WHEN PTYPE IN (5,6,7,10,12,13,14) THEN 'Fee' 
                        WHEN PTYPE = 8 THEN 'Gift card' 
                        WHEN PTYPE = 9 THEN 'Free gift card' 
                END AS "Item"
                ,inl.quantity AS "Quantity"
                ,inl.total_amount AS "Total Sale Amount"
                ,inl.total_amount - inl.net_amount AS "Total Tax Amount"
                ,vat.global_id AS "Tax Rate"
        FROM
                shifts crl
        JOIN
                evolutionwellness.centers c
                ON c.id = crl.cash_register_center
        LEFT JOIN
                cash_register_log t    
                ON  t.cash_register_center = crl.cash_register_center
                AND t.cash_register_id = crl.cash_register_id
                AND t.log_time = crl.register_close_long
                AND t.log_type = 'CLOSE_CASH_REGISTER'                
        JOIN
                evolutionwellness.employees emp
                ON emp.center = t.employee_center
                AND emp.id = t.employee_id        
        JOIN
                evolutionwellness.persons p
                ON p.center = emp.personcenter
                AND p.id = emp.personid
        JOIN
                evolutionwellness.cashregistertransactions crt
                ON crt.crcenter = crl.cash_register_center
                AND crt.crid = crl.cash_register_id
                AND crt.transtime BETWEEN crl.register_open_long AND crl.register_close_long
                AND cr_action IS NULL        
        JOIN
                evolutionwellness.invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id
        JOIN
                evolutionwellness.invoice_lines_mt inl 
                ON inv.center = inl.center 
                AND inv.id = inl.id
                AND inl.total_amount != 0
        JOIN
                evolutionwellness.products pro
                ON pro.center = inl.productcenter
                AND pro.id = inl.productid
        LEFT JOIN
                evolutionwellness.product_account_configurations pac
                ON pac.id = pro.product_account_config_id
        LEFT JOIN
                evolutionwellness.accounts ac
                ON ac.globalid = pac.sales_account_globalid
                AND ac.center = pro.center 
        LEFT JOIN
                evolutionwellness.account_vat_type_group vat
                ON vat.id = ac.account_vat_type_group_id
                AND vat.account_center = ac.center
                AND vat.account_id = ac.id                                        
        )t 
GROUP BY
        t."Club"
        ,t."Club Number"	
        ,t."Club Code"
        ,t."Operator"	
        ,t."Shift Start Time"
        ,t."Shift End Time"
        ,t."Transaction Day"
        ,t."Workstation"
        ,t."Item"
        ,t."Tax Rate"                              