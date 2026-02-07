SELECT 
   ise.*,
   p.external_id AS ActualSalespersonExternalId
FROM
   goodlife.invoice_sales_employee ise
JOIN
   goodlife.employees emp
ON
   emp.center = ise.sales_employee_center
AND emp.id = ise.sales_employee_id
AND ise.stop_time IS NULL
JOIN
   goodlife.persons p
ON
   p.center = emp.personcenter
AND p.id = emp.personid
WHERE
    ise."start_time" BETWEEN
    CASE
        WHEN $$offset$$=-1
        THEN 0
        ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
    END
    AND CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000