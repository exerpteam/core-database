-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    new_sp.from_date                         AS "Effective Change Date",
    longtodateC(new_sp.entry_time,sc.center) AS "Date of Change",
    p.center ||'p'|| p.id                    AS "Employee Id",
    p.external_id,
    CASE
        WHEN p.persontype = 0
        THEN 'Private'
        WHEN p.persontype = 1
        THEN 'Student'
        WHEN p.persontype = 2
        THEN 'Staff'
        WHEN p.persontype = 3
        THEN 'Friend'
        WHEN p.persontype = 4
        THEN 'Corporate'
        WHEN p.persontype = 5
        THEN 'One Man Corporate'
        WHEN p.persontype = 6
        THEN 'Family'
        WHEN p.persontype = 7
        THEN 'Senior'
        WHEN p.persontype = 7
        THEN 'Guest'
        WHEN p.persontype = 7
        THEN 'Child'
        WHEN p.persontype = 7
        THEN 'External_Staff'
        ELSE 'Unknown'
    END AS "Person Type",
    new_sp.subscription_center||'ss'||new_sp.subscription_id as "Subscription ID",
    new_sp.price AS "New Price",
    old_sp.price AS "Old Price"
   
FROM
    subscription_price new_sp
JOIN
    subscription_price old_sp
ON
    old_sp.subscription_center=new_sp.subscription_center
AND old_sp.subscription_id=new_sp.subscription_id
JOIN
    subscriptions sc
ON
    sc.center=new_sp.subscription_center
AND sc.id= new_sp.subscription_id
JOIN
    persons p
ON
    p.center=sc.owner_center
AND p.id=sc.owner_id
WHERE
    new_sp.from_date = old_sp.to_date + 1
AND new_sp.cancelled=false
AND old_sp.cancelled=false
AND sc.center IN ($$center$$)
AND new_sp.from_date BETWEEN  $$Effective_Change_Date_From$$ AND $$Effective_Change_Date_To$$;