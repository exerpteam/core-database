SELECT
         p.center||'p'||p.id AS personID
         ,longtodatec(sao.creation_time,sao.center_id) AS creationdate
         ,mpr_addon.cached_productname AS Addon_name
         ,empp.fullname
         ,emp.center||'emp'||empp.id AS employeeID
FROM 
        subscription_addon sao
JOIN  
        MASTERPRODUCTREGISTER mpr_addon 
        ON mpr_addon.id = sao.ADDON_PRODUCT_ID
JOIN
        subscriptions s
        ON s.center = sao.subscription_center
        AND s.id = sao.subscription_id
JOIN
        persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id  
JOIN
        employees emp
        ON emp.center = sao.employee_creator_center
        AND emp.id = sao.employee_creator_id
JOIN
        persons empp 
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid                             
WHERE 
        p.center||'p'||p.id = :personID