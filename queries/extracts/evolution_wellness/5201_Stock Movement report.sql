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
        c.name AS "Center"
        ,longtodatec(inv.book_time,inv.product_center) AS "Book TIme"
        ,prod.name AS "Product Name"
        ,prod.external_id AS "External ID"
        ,prod.globalid AS "Global Name"
        ,inv.type AS "Type"
        ,inv.quantity 
        ,inv.unit_value AS "Cost Price"
        ,prod.price AS "Selling Price"
        ,inl.net_amount AS "Discounted price"
        ,CASE
                WHEN inv.type IN ('DELIVERY','RETURN') THEN inv.quantity * inv.unit_value
                ELSE NULL
        END AS "Debit"
        ,CASE
                WHEN inv.type NOT IN ('DELIVERY','RETURN') THEN inv.quantity * inv.unit_value
                ELSE NULL
        END AS "Credit"                
        ,inv.balance_quantity AS "Total units"
        ,inv.balance_value AS "Total amount"
        ,inv.coment AS "Comment"
        ,p.fullname AS "Employee"
        ,prod.center||'prod'||prod.id AS "Product ID"
        ,longtodatec(inv.entry_time,inv.product_center) AS "Entry TIme"
        ,CASE
                WHEN inv.ref_type = 'INVOICE_LINE' THEN inv.ref_center||'inv'||inv.ref_id||'In'||inv.ref_subid
                WHEN inv.ref_type = 'DELIVERY_LINE' THEN inv.ref_center||'del'||inv.ref_id||'dl'||inv.ref_subid
                WHEN inv.ref_type='CREDIT_LINE' THEN inv.ref_center||'cred'||inv.ref_id||'cnl'||inv.ref_subid
                ELSE NULL
        END AS "Ref"              
FROM 
        evolutionwellness.inventory_trans inv
JOIN
        evolutionwellness.products prod
        ON prod.center = inv.product_center
        AND prod.id = inv.product_id
JOIN
        evolutionwellness.centers c
        ON c.id = prod.center 
JOIN
        evolutionwellness.employees emp
        ON emp.center = inv.employee_center
        AND emp.id = inv.employee_id
JOIN
        evolutionwellness.persons p
        ON p.center = emp.personcenter
        AND p.id = emp.personid  
JOIN
        params
        ON params.center_id = c.id 
LEFT JOIN
        evolutionwellness.invoice_lines_mt inl
        ON inl.center = inv.ref_center
        AND inl.id = inv.ref_id
        AND inl.subid = inv.ref_subid
        AND inv.ref_type = 'INVOICE_LINE'
WHERE 
        inv.product_center IN (:Scope)
        AND
        inv.book_time BETWEEN params.FromDate AND params.ToDate