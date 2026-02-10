-- The extract is extracted from Exerp on 2026-02-08
-- ST-9680
SELECT
    pd.name AS "Product Name",
    p.external_id as "Assigned Employee",
    p_selling.external_id as "Selling Employee"
FROM
    lifetime.subscription_sales ss
JOIN
    subscriptions sub
ON
    sub.center = ss.subscription_center
AND sub.id = ss.subscription_id 
JOIN
    persons p
ON
    p.center = sub.assigned_staff_center
AND p.id = sub.assigned_staff_id
JOIN
    products pd 
ON
   pd.center = sub.subscriptiontype_center
AND
   pd.id = sub.subscriptiontype_id   
JOIN    
   employees e
ON
  e.center = ss.employee_center
AND
  e.id = ss.employee_id   
JOIN
   persons p_selling
ON 
   p_selling.center = e.personcenter 
AND
   p_selling.id = e.personid      
WHERE 
sub.center = 238
AND 
sub.state in (2,4,8)
AND ss.sales_date BETWEEN :To_Date AND :From_Date

   
    
